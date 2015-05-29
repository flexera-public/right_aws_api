#--
# Copyright (c) 2015 RightScale, Inc.
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
    module MWS

      # Request signer for MWS services.
      class RequestSigner < Routine

        # RequestSigner error
        class Error < Error
        end

        # Authenticates an AWS request
        #
        def process
          # Make sure all the required params are set
          @data[:request][:params]['AWSAccessKeyId'] = @data[:credentials][:aws_access_key_id]
          @data[:request][:params]['Version']      ||= @data[:options][:api_version]
          # Figure out what service is being invoked
          service_path = ''
          if @data[:options][:cloud][:service_path]
            service_path = '%s/%s' % [@data[:options][:cloud][:service_path], @data[:request][:params]['Version']]
          end
          # Compile a final request path
          path = Utils::join_urn(@data[:connection][:uri].path, @data[:request][:relative_path], service_path)
          # Sign the request
          signed_path = Utils::AWS::sign_v2_signature(
            data[:credentials][:aws_secret_access_key],
            data[:request][:params] || {},
            data[:request][:verb],
            data[:connection][:uri].host,
            path
          )
          @data[:request][:path] = '%s?%s' % [path, signed_path]
        end
      end

    end
  end
end
