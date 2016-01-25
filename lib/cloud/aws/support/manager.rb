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

require "cloud/aws/base/helpers/utils"
require "cloud/aws/support/routines/request_signer"
require "cloud/aws/base/parsers/response_error"

module RightScale
  module CloudApi
    module AWS
      
      # Support namespace
      #
      # @api public
      #
      module Support

        # Amazon Support compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  # Create a manager
        #  support = RightScale::CloudApi::AWS::Support::Manager.new(
        #          ENV['AWS_ACCESS_KEY_ID'],
        #          ENV['AWS_SECRET_ACCESS_KEY'],
        #          ENV['AWS_ACCOUNT_NUMBER'],
        #          'https://support.us-east-1.amazonaws.com')
        class Manager < CloudApi::Manager
        end


        # Amazon Support compatible manager (thread unsafe).
        #
        # @see Manager
        #
        class ApiManager < AWS::ApiManager

          # Support Error
          class Error < CloudApi::Error
          end

          # Default API version for Support service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2013-04-15'

          set_routine CloudApi::RetryManager
          set_routine CloudApi::RequestInitializer
          set_routine AWS::Support::RequestSigner
          set_routine CloudApi::RequestGenerator
          set_routine CloudApi::RequestAnalyzer
          set_routine CloudApi::ConnectionProxy
          set_routine CloudApi::ResponseAnalyzer
          set_routine CloudApi::ResponseParser
          set_routine CloudApi::ResultWrapper

          error_pattern :abort_on_timeout,     :path     => /Action=(Create|Resolve)/
          error_pattern :retry,                :response => /InternalError|Unavailable/i
          error_pattern :disconnect_and_abort, :code     => /5..|403|408/
          error_pattern :disconnect_and_abort, :code     => /4../, :if => Proc.new{ |opts| rand(100) < 10 }

          set :response_error_parser => Parser::AWS::ResponseErrorV2
          
          cache_pattern :verb  => /get|post/,
                        :path  => /Action=Describe/,
                        :if    => Proc::new{ |o| (o[:params].keys - COMMON_QUERY_PARAMS)._blank? },
                        :key   => Proc::new{ |o| o[:params]['Action'] },
                        :sign  => Proc::new{ |o| o[:response].body.to_s.sub(%r{<RequestId>.+?</RequestId>}i,'') }
        end
      end
    end
  end
end
