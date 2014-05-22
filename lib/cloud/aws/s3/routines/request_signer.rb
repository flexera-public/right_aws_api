#--
# Copyright (c) 2013 RightScale, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module RightScale
  module CloudApi
    module AWS
      module S3

        # S3 Request signer
        class RequestSigner < CloudApi::Routine

          # S3 Request signer Error
          class Error < CloudApi::Error
          end

          # This guys are used to sign a request
          SUB_RESOURCES = %w{
            acl
            cors
            delete
            lifecycle
            location
            logging
            notification
            policy
            requestPayment
            tagging
            torrent
            uploads
            versionId
            versioning
            versions
            website
          }


          # Using Query String API Amazon allows to override some of response headers:
          # 
          # response-content-type response-content-language response-expires
          # reponse-cache-control response-content-disposition response-content-encoding
          # 
          # @see http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTObjectGET.html?r=2145
          #
          OVERRIDE_RESPONSE_HEADERS = /^response-/ 

          # One year in seconds
          ONE_YEAR_OF_SECONDS = 365*60*60*24
          
          # Authenticates an S3 request
          #
          # @return [void]
          #
          # @example
          #  # no example
          #
          def process
            # Extract sub-resource(s).
            # Sub-resources are acl, torrent, versioning, location etc.
            sub_resources = {}
            @data[:request][:params].each do |key, value|
              sub_resources[key] = (value._blank? ? nil : value) if SUB_RESOURCES.include?(key) || key[OVERRIDE_RESPONSE_HEADERS]
            end

            # Extract bucket name and object path
            if @data[:request][:bucket]._blank?
              # This is a very first attempt:
              # 1. extract the bucket name from the path
              # 2. save the bucket into request data vars
              bucket_name, @data[:request][:relative_path] = @data[:request][:relative_path].to_s[/^([^\/]*)\/?(.*)$/] && [$1, $2]
              @data[:request][:bucket] = bucket_name
              # Static path is the path that the original URL has.
              # 1. For Amazon it is always ''.
              # 2. For Euca it is usually a non-blank string.
              static_path = @data[:connection][:uri].path
              # Add trailing '/' to the path unless it is.
              static_path = "#{static_path}/" unless static_path[/\/$/]
              # Store the path: we may need it for signing redirects later.
              @data[:request][:static_path] = static_path
            else
              # This is a retry or a redirect:
              # 1. Extract the bucket name from the request data;
              # 2. Get rid of the path the remote server sent in the location header. We are
              #    re-signing the request and have to build everything from the scratch.
              #    In the crazy case when the new location has path differs from the original one
              #    we are screwed up and we will get "SignatureDoesNotMatch" error. But this does
              #    not seem to be the case for Amazon or Euca.
              bucket_name = @data[:request][:bucket]
              # Revert static path back to the original value.
              static_path = @data[:request][:static_path]
              @data[:connection][:uri].path = static_path
            end

            # Escape that part of the path that may have UTF-8 chars (in S3 Object name for instance).
            # Amazon wants them to be escaped before we sign the request.
            #
            # P.S. Escape AFTER we extract bucket name.
            @data[:request][:relative_path] = Utils::AWS::amz_escape(@data[:request][:relative_path])

            # Calculate a canonical path (bucket part must end with '/')
            bucket_string      = Utils::AWS::is_dns_bucket?(bucket_name) ? "#{bucket_name}/" : bucket_name.to_s
            canonicalized_path = Utils::join_urn(static_path,
                                                 bucket_string,
                                                 @data[:request][:relative_path],
                                                 sub_resources ){ |value| value } # pass this block to avoid escaping: Amazon does not like escaped things in canonicalized_path

            # Make sure headers required for authentication are set
            unless @data[:options][:cloud][:link]
              # Make sure 'content-type' is set.
              # P.S. Ruby 2.1+ sets 'content-type' by default for POST and PUT requests.
              #      So we need to include it into our signature to avoid the error below:
              #      'The request signature we calculated does not match the signature you provided.
              #       Check your key and signing method.'
              @data[:request][:headers].set_if_blank('content-type', 'application/octet-stream')
              # REST Auth:
              unless @data[:request][:body]._blank?
                # Fix body if it is a Hash instance
                if @data[:request][:body].is_a?(Hash)
                  @data[:request][:body] = Utils::contentify_body(@data[:request][:body], @data[:request][:headers]['content-type'])
                end
                # Calculate 'content-md5' when possible (some API calls wanna have it set)
                if @data[:request][:body].is_a?(String)
                  @data[:request][:headers]['content-md5'] = Base64::encode64(Digest::MD5::digest(@data[:request][:body])).strip
                end
              end
              # Set date
              @data[:request][:headers].set_if_blank('date', Time::now.utc.httpdate)
              # Sign a request
              signature = Utils::AWS::sign_s3_signature( @data[:credentials][:aws_secret_access_key],
                                                         @data[:request][:verb],
                                                         canonicalized_path,
                                                         @data[:request][:headers])
              @data[:request][:headers]['authorization'] = "AWS #{@data[:credentials][:aws_access_key_id]}:#{signature}"
            else
              # @see http://docs.amazonwebservices.com/AmazonS3/latest/dev/RESTAuthentication.html
              #
              # Amazon: ... We assume that when a browser makes the GET request, it won't provide a Content-MD5 or a Content-Type header,
              #  nor will it set any x-amz- headers, so those parts of the StringToSign are left blank. ...
              #
              # Only GET requests!
              raise Error::new("Only GET requests are supported by S3 Query String API") unless @data[:request][:verb] == :get
              # Expires
              expires = Utils::dearrayify(@data[:request][:headers]['expires'].first || (Time.now.utc.to_i + ONE_YEAR_OF_SECONDS))
              expires = expires.to_i unless expires.is_a?(Fixnum)
              # QUERY STRING AUTH: ('expires' and 'x-amz-*' headers are not supported)
              @data[:request][:params]['Expires']  = expires
              @data[:request][:headers]['expires'] = expires # a hack to sign a record
              @data[:request][:headers].dup.each do |header, values|
                @data[:request][:headers].delete(header) unless header.to_s[/(^x-amz-)|(^expires$)/]
              end
              @data[:request][:params]['AWSAccessKeyId'] = @data[:credentials][:aws_access_key_id]
              # Sign a request
              signature = Utils::AWS::sign_s3_signature( @data[:credentials][:aws_secret_access_key],
                                                         @data[:request][:verb],
                                                         canonicalized_path,
                                                         @data[:request][:headers] )
              @data[:request][:params]['Signature'] = signature
              # we dont need this header any more
              @data[:request][:headers].delete('expires')
            end

            # Sub-domain compatible buckets vs incompatible ones
            if !@data[:options][:cloud][:no_subdomains] && Utils::AWS::is_dns_bucket?(bucket_name)
              # DNS compatible bucket name:
              #
              # Figure out if we need to add bucket name into the host name. It is rediculous but
              # sometimes Amazon returns a redirect to a host with the bucket name already mixed in
              # but sometimes without.
              # The only thing we can do so far is to check if the host name starts with the bucket
              # and the name is at least 4th level DNS name.
              #
              # Examples:
              #   * my-bucket.s3-ap-southeast-2.amazonaws.com
              #   * my-bucket.s3.amazonaws.com
              #   * s3.amazonaws.com
              #
              # P.S. This assumtion will not work for any other providers but we will figure it out later
              #      if we support any. The only other provider we support is Eucalyptus but it always
              #      expects that the bucket goes into path and never into the host therefore we are
              #      OK with Euca (Euca is expected to be run with :no_subdomains => true).
              #
              unless @data[:connection][:uri].host[/^#{bucket_name}\..+\.[^.]+\.[^.]+$/]
                # If there was a redirect and it had 'location' header then there is nothing to do with the host
                # otherwise we have to add the bucket to the host.
                # P.S. When Amazon returns a redirect (usually 301) with the new host in the message body
                # the new host does not have the bucket name in it. But if it is 307 and the host is in the location
                # header then that host name already includes the bucket in it. Grrrr....
                @data[:connection][:uri].host = "#{bucket_name}.#{@data[:connection][:uri].host}"
              end
              @data[:request][:path] = Utils::join_urn( @data[:connection][:uri].path,
                                                        @data[:request][:relative_path],
                                                        @data[:request][:params] )
            else
              # Old incompatible or Eucalyptus
              @data[:request][:path] = Utils::join_urn( @data[:connection][:uri].path,
                                                        "#{bucket_name}",
                                                        @data[:request][:relative_path],
                                                        @data[:request][:params] )
            end

            # Host should be set for REST requests (and should not affect on Query String ones)
            @data[:request][:headers]['host'] = @data[:connection][:uri].host

            # Finalize data
            if @data[:options][:cloud][:link]
              # Amazon supports only some GET requests without body and any headers:
              # Return the link
              uri = @data[:connection][:uri].clone
              uri.path, uri.query = @data[:request][:path].split('?')
              @data[:result] = {
                "verb"    => @data[:request][:verb].to_s,
                "link"    => uri.to_s,
                "headers" => @data[:request][:headers]
              }
              # Query Auth:we should stop here because we just generated a link for the third part usage
              @data[:vars][:system][:done]   = true
            end
          end
        end

      end
    end
  end
end