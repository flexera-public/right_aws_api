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
        module Link

          # S3 Request signer
          class RequestSigner < S3::RequestSigner


            # Authenticates an S3 request
            #
            # @return [void]
            #
            # @example
            #  # no example
            #
            def process
              fail Error::new("Only GET method is supported") unless @data[:request][:verb] == :get
              fail Error::new("Body must be blank")           unless @data[:request][:body]._blank?
              fail Error::new("Headers must be blank")        unless @data[:request][:headers]._blank?

              uri        = @data[:connection][:uri]
              access_key = @data[:credentials][:aws_access_key_id]
              secret_key = @data[:credentials][:aws_secret_access_key]
              bucket     = @data[:request][:bucket]
              object     = @data[:request][:relative_path]
              params     = @data[:request][:params]
              verb       = @data[:request][:verb]

              bucket, object = compute_bucket_name_and_object_path(bucket, object)
              uri            = compute_host(bucket, uri)

              compute_params!(params, access_key)

              # Set Auth param
              signature = compute_signature(secret_key, verb, bucket, object, params)
              params['Signature'] = signature

              # Compute href
              path                = compute_path(bucket, object, params)
              uri.path, uri.query = path.split('?')
              @data[:result]      = uri.to_s

              # Set completion flag
              @data[:vars][:system][:done] = true
            end


            # Sets response params
            #
            # @param [Hash] params
            #
            # @return [Hash]
            #
            def compute_params!(params, access_key)
              # Expires
              expires   = params['Expires']
              expires ||= Time.now.utc.to_i + ONE_YEAR_OF_SECONDS
              expires   = expires.to_i unless expires.is_a?(Fixnum)
              params['Expires']        = expires
              params['AWSAccessKeyId'] = access_key
              params
            end


            # Computes signature
            #
            # @param [String] secret_key
            # @param [String] verb
            # @param [String] bucket
            # @param [Hash]   params
            #
            # @return [String]
            #
            def compute_signature(secret_key, verb, bucket, object, params)
              can_path = compute_canonicalized_path(bucket, object, params)
              Utils::AWS::sign_s3_signature(secret_key, verb, can_path, { 'expires' => params['Expires'] })
            end
          end

        end
      end
    end
  end
end
