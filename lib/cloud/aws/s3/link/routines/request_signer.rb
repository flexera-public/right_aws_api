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

              uri            = @data[:connection][:uri]
              bucket         = @data[:request][:bucket]
              object         = @data[:request][:relative_path]
              bucket, object = compute_bucket_name_and_object_path(bucket, object)
              uri            = compute_host(bucket, uri)

              @data[:request][:path] = compute_path(bucket,object)

              Utils::AWS::sign_v4_signature(
                @data[:credentials][:aws_access_key_id],
                @data[:credentials][:aws_secret_access_key],
                @data[:connection][:uri].host,
                @data[:request],
                :query_params
              )

              # Compute href
              path                = @data[:request][:path]
              uri.path, uri.query = path.split('?')
              @data[:result]      = uri.to_s

              # Set completion flag
              @data[:vars][:system][:done] = true
            end

          end

        end
      end
    end
  end
end
