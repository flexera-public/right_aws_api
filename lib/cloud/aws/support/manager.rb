#--
# Copyright (c) 2016 RightScale, Inc.
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

require "cloud/aws/support/parsers/response_error"
require "cloud/aws/support/routines/request_signer"

module RightScale
  module CloudApi
    module AWS
      module Support

        # AWS Support manager
        #
        # @example
        #   s = RightScale::CloudApi::AWS::Support::Manager.new(key,  secret, 'https://support.us-east-1.amazonaws.com')
        #
        #   s.DescribeCases #=>
        #       {"cases"=>[]}
        #
        #   s.DescribeServices( body: {"Language" => "en"} ) #=>
        #       {"services"=>[{"__type"=>"Service", "categories"=> ... }
        #
        class Manager < AWS::Manager
        end

        class ApiManager < AWS::ApiManager

          # A list of common AWS API params
          COMMON_QUERY_PARAMS = [
            'AuthParams',
            'AWSAccessKeyId',
            'Expires',
            'SecurityToken',
            'Signature',
            'SignatureMethod',
            'SignatureVersion',
            'Timestamp',
            'Version',
          ]

          set_routine CloudApi::RetryManager
          set_routine CloudApi::RequestInitializer
          set_routine AWS::Support::RequestSigner
          set_routine CloudApi::RequestGenerator
          set_routine CloudApi::RequestAnalyzer
          set_routine CloudApi::ConnectionProxy
          set_routine CloudApi::ResponseAnalyzer
          set_routine CloudApi::CacheValidator
          set_routine CloudApi::ResponseParser
          set_routine CloudApi::ResultWrapper

          set :response_error_parser => Parser::AWS::Support::ResponseError

          DEFAULT_API_VERSION = '2013-04-15'

          error_pattern :retry,                :response => /InternalError|Unavailable/i
          error_pattern :disconnect_and_abort, :code     => /5..|403|408/

          def api(action, params={}, &block)
            opts = {}
            opts[:headers] = params.delete(:headers) || {}
            opts[:headers]['x-amz-target'] = action
            opts[:body]    = params.delete(:body)
            opts[:params]  = parametrize(params)
            process_api_request(:post, '', opts, &block)
          end

        end
      end
    end
  end
end
