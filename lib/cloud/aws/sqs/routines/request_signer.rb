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
      module SQS
        # SQS Request signer
        class RequestSigner < CloudApi::Routine

          # RequestSigner error
          class Error < CloudApi::Error
          end

          # Authenticates an SQS request
          #
          # @return [void]
          #
          # @example
          #  no example
          #
          def process
            # Compile a final request path
            @data[:request][:path] = Utils::join_urn(@data[:connection][:uri].path, @data[:request][:relative_path])

            # Swap query params and body
            @data[:request][:params]['Version'] ||= @data[:options][:api_version]
            #@data[:request][:body]   = Utils::params_to_urn(@data[:request][:params]){ |value| Utils::AWS::amz_escape(value) }
            #@data[:request][:params] = {}

            Utils::AWS::sign_v4_signature(
              @data[:credentials][:aws_access_key_id],
              @data[:credentials][:aws_secret_access_key],
              @data[:connection][:uri].host,
              @data[:request]
            )
          end
        end
      end
    end
  end
end
