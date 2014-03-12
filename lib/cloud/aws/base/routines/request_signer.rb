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

      # Request signer for AWS services.
      class RequestSigner < CloudApi::Routine

        # RequestSigner error
        class Error < CloudApi::Error
        end

        # Use POST verb if GET's path is getting too big.
        MAX_GET_REQUEST_PATH_LENGTH = 2000

        # Authenticates an AWS request
        #
        # @return [void]
        #
        # @example
        #  no example
        #
        def process
          # Make sure all the required params are set
          @data[:request][:params]['AWSAccessKeyId'] = @data[:credentials][:aws_access_key_id]
          @data[:request][:params]['Version']      ||= @data[:options][:api_version]
          # Compile a final request path
          @data[:request][:path] = Utils::join_urn(@data[:connection][:uri].path, @data[:request][:relative_path])
          # Sign the request
          sign_proc = Proc::new do |data|
            Utils::AWS::sign_v2_signature( data[:credentials][:aws_secret_access_key],
                                           data[:request][:params] || {},
                                           data[:request][:verb],
                                           data[:connection][:uri].host,
                                           data[:request][:path] )
          end
          signed_path = sign_proc.call(@data)
          # Rebuild the request as POST if its path is too long
          if signed_path.size > MAX_GET_REQUEST_PATH_LENGTH && @data[:request][:verb] == :get
            @data[:request][:verb] = :post
            signed_path = sign_proc.call(@data)
          end
          # Set new path or body and content-type
          case @data[:request][:verb]
          when :get
            @data[:request][:path] << "?#{signed_path}"
          when :post
            @data[:request][:body] = signed_path
            @data[:request][:headers]['content-type'] = 'application/x-www-form-urlencoded; charset=utf-8'
          else
            fail Error::new("Unsupported HTTP verb: #{@data[:request][:verb]}")
          end
        end
      end
        
    end
  end
end