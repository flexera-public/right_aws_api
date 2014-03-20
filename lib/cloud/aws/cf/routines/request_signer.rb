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
      module CF
        
        # API request signer for CF service.
        class RequestSigner < CloudApi::Routine

          # CF RequestSigner Error
          class Error < CloudApi::Error
          end

          # Authenticates a CloudFront request
          #
          # @return [void]
          #
          # @example
          #  # qno example
          #
          def process
            # Fix body
            unless @data[:request][:body]._blank?
              # Make sure 'content-type' is set if we have a body
              @data[:request][:headers].set_if_blank('content-type', 'application/xml' )
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
            signature = Utils::AWS::sign(@data[:credentials][:aws_secret_access_key], Utils::dearrayify(@data[:request][:headers]['date']))
            @data[:request][:headers]['authorization'] = "AWS #{@data[:credentials][:aws_access_key_id]}:#{signature}"
            # Set path
            @data[:request][:path] = Utils::join_urn(@data[:connection][:uri].path, @data[:options][:api_version], @data[:request][:relative_path], @data[:request][:params])
          end
        end
        
      end
    end
  end
end