# -*- coding: utf-8 -*-
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
            uri            = @data[:connection][:uri]
            body           = @data[:request][:body]
            bucket         = @data[:request][:bucket]
            object         = @data[:request][:relative_path]
            bucket, object = compute_bucket_name_and_object_path(bucket, object)
            body           = compute_body(body, @data[:request][:headers]['content-type'])
            uri            = compute_host(bucket, uri)

            compute_headers!(@data[:request][:headers], body, uri.host)

            @data[:connection][:uri]        = uri
            @data[:request][:bucket]        = bucket
            @data[:request][:relative_path] = object
            @data[:request][:body]          = body
            @data[:request][:path]          = compute_path(bucket, object)

            Utils::AWS::sign_v4_signature(
              @data[:credentials][:aws_access_key_id],
              @data[:credentials][:aws_secret_access_key],
              @data[:connection][:uri].host,
              @data[:request]
            )
          end


          # Extracts S3 bucket name and escapes relative path
          #
          # @param [String] bucket
          # @param [String] relative_path
          #
          # @return [Array]  [bucket, escaped_relative_path]
          #
          # @example
          #   subject.compute_bucket_name_and_object_path(nil, 'my-test-bucket/foo/bar/банана.jpg') #=>
          #     ['my-test-bucket', 'foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg']
          #
          def compute_bucket_name_and_object_path(bucket, relative_path)
            return [bucket, relative_path] if bucket
            # This is a very first attempt:
            relative_path.to_s[/^([^\/]*)\/?(.*)$/]
            # Escape part of the path that may have UTF-8 chars (in S3 Object name for instance).
            # Amazon wants them to be escaped before we sign the request.
            # P.S. but do not escape "/" (signature v4 does not like this)
            #
            new_bucket = $1
            pre_object = $2.to_s
            object     = pre_object.split('/').map{|i| Utils::AWS::amz_escape(i)}.join('/')
            # Preserve '/' if it is the last symbol of the object because it is an operation on a folder
            object    += '/' if object.length > 0 && pre_object[/\/$/]
            [ new_bucket, object ]
          end


          # Figure out if we need to add bucket name into the host name
          #
          # If there was a redirect and it had 'location' header then there is nothing to do
          # with the host, otherwise we have to add the bucket to the host.
          #
          # P.S. When Amazon returns a redirect (usually 301) with the new host in the message
          # body, the new host does not have the bucket name in it. But if it is 307 and the
          # host is in the location header then that host name already includes the bucket in it.
          # The only thing we can do so far is to check if the host name starts with the bucket
          # and the name is at least 4th level DNS name.
          #
          # Examples:
          #   * my-bucket.s3-ap-southeast-2.amazonaws.com
          #   * my-bucket.s3.amazonaws.com
          #   * s3.amazonaws.com
          #
          # @param [String] bucket
          # @param [URI]    uri
          #
          # @return [URI]
          #
          def compute_host(bucket, uri)
            return uri unless is_dns_bucket?(bucket)
            return uri if uri.host[/^#{bucket}\..+\.[^.]+\.[^.]+$/]
            uri.host = "#{bucket}.#{uri.host}"
            uri
          end


          # Returns response body
          #
          # @param [Object] body
          # @param [String] content_type
          #
          # @return [Object]
          #
          def compute_body(body, content_type)
            return body if body.nil?
            # Make sure it is a String instance
            return body unless body.is_a?(Hash)
            Utils::contentify_body(body, content_type)
          end


          # Sets response headers
          #
          # @param [Hash]   headers
          # @param [String] body
          # @param [String] host
          #
          # @return [Hash]
          #
          def compute_headers!(headers, body, host)
            # Make sure 'content-type' is set.
            # P.S. Ruby 2.1+ sets 'content-type' by default for POST and PUT requests.
            #      So we need to include it into our signature to avoid the error below:
            #      'The request signature we calculated does not match the signature you provided.
            #       Check your key and signing method.'
            headers.set_if_blank('content-type', 'binary/octet-stream')
            headers
          end


          # Builds request path
          #
          # @param [String] bucket
          # @param [String] object
          # @param [Hash]   params
          #
          # @return [String]
          #
          def compute_path(bucket, object)
            data = []
            data << bucket unless is_dns_bucket?(bucket)
            data << object
            Utils::join_urn(*data)
          end

          # Returns +true+ if DNS compatible buckets are enabled (default) and the
          # given bucket is DNS compatible
          #
          # @param [String] bucket
          # @return [Boolean]
          #
          def is_dns_bucket?(bucket)
            return false if no_dns_buckets?
            Utils::AWS::is_dns_bucket?(bucket)
          end


          def no_dns_buckets?
            !!@data[:options][:cloud][:no_dns_buckets]
          end

        end
      end
    end
  end
end
