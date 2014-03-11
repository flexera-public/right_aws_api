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
require "cloud/aws/base/routines/request_signer"
require "cloud/aws/base/parsers/response_error"

module RightScale
  module CloudApi
    module AWS

      # Thread safe parent class for almost all the AWS services.
      class Manager < CloudApi::Manager
      end

      # Thread un-safe parent class for almost all the AWS services.
      class  ApiManager < CloudApi::ApiManager
        class Error < CloudApi::Error
        end

        # A list of common AWS API params
        COMMON_QUERY_PARAMS = %w{
          Action
          AWSAccessKeyId
          Expires
          SecurityToken
          Signature
          SignatureMethod
          SignatureVersion
          Timestamp
          Version
        }
        
        include Mixin::QueryApiPatterns

        set_routine CloudApi::RetryManager
        set_routine CloudApi::RequestInitializer
        set_routine AWS::RequestSigner
        set_routine CloudApi::RequestGenerator
        set_routine CloudApi::RequestAnalyzer
        set_routine CloudApi::ConnectionProxy
        set_routine CloudApi::ResponseAnalyzer
        set_routine CloudApi::CacheValidator
        set_routine CloudApi::ResponseParser
        set_routine CloudApi::ResultWrapper
        
        set :response_error_parser => Parser::AWS::ResponseErrorV1

        # Initializes the manager.
        #
        # @param [String] aws_access_key_id Amazon AWS access key id.
        # @param [String] aws_secret_access_key Amazon secret AWS access key.
        # @param [String] endpoint Cloud endpoint.
        # @param [Hash] options See {RightScale::CloudApi::ApiManager#initialize} options
        #
        # @return [RightScale::CloudApi::AWS::ApiManager]
        #
        def initialize(aws_access_key_id, aws_secret_access_key, endpoint, options={})
          credentials = { :aws_access_key_id     => aws_access_key_id,
                          :aws_secret_access_key => aws_secret_access_key }
          super(credentials, endpoint, options)
        end
        
        # Makes a raw API call to AWS compatible service by the mqthod name.
        #
        # @param [String] action Depends on the selected service/endpoint.
        #   See {http://aws.amazon.com/documentation/}
        # @param [Hash] params A set or extra parameters.
        # @option params [Hash,String] :body The request body.
        # @option params [Hash] :headers The request headers.
        # @option params [Hash] :options The request options (RightScale::CloudApi::ApiManager.process_api_request).
        # @option params [Hash] :params The extra set of URL params.
        #
        # @return [Object] Usually a Hash with data.
        #
        # @example
        #  ec2.api('DescribeImages')
        #
        # @example
        #  ec2.api('DescribeInstances', 'InstanceId' => ['i-00000001', 'i-00000002'])
        #
        def api(action, params={}, &block)
          params['Action'] ||= action.to_s._snake_case._camelize
          opts = {}
          opts[:body]    = params.delete(:body)
          opts[:headers] = params.delete(:headers) || {}
          opts[:options] = params.delete(:options) || {}
          opts[:params]  = parametrize(params)
          process_api_request(:get, '', opts, &block)
        end
        
        # Parametrize data to the format that Amazon EC2 and compatible services accept.
        # See {RightScale::CloudApi::Utils::AWS.parametrize} for more examples.
        #
        # @return [Hash] A hash of data in the format Amazon want to get.
        #
        # @example
        #  parametrize( 'ParamA'             => 'a',
        #               'ParamB'             => ['b', 'c'],
        #               'ParamC.?.Something' => ['d', 'e'],
        #               'Filter'             => [ { 'Key' => 'A', 'Value' => ['aa','ab']},
        #                                         { 'Key' => 'B', 'Value' => ['ba','bb']}] ) #=>
        #    {
        #      "Filter.1.Key"       => "A",
        #      "Filter.1.Value.1"   => "aa",
        #      "Filter.1.Value.2"   => "ab",
        #      "Filter.2.Key"       => "B",
        #      "Filter.2.Value.1"   => "ba",
        #      "Filter.2.Value.2"   => "bb",
        #      "ParamA"             => "a",
        #      "ParamB.1"           => "b",
        #      "ParamB.2"           => "c",
        #      "ParamC.1.Something" => "d",
        #      "ParamC.2.Something" => "e"
        #    }
        #
        def parametrize(*args)
          Utils::AWS.parametrize(*args)
        end
        alias_method :p9e, :parametrize

        # Provides an ability to call methods by their API action names.
        #
        # @example
        #  # the calls below produce the same result:
        #  # way #1
        #  ec2.api('DescribeInstances', 'InstanceId' => ['i-00000001', 'i-00000002'])
        #  # way #2
        #  ec2.DescribeInstances('InstanceId' => ['i-00000001', 'i-00000002'])
        #
        def method_missing(method_name, *args, &block)
          begin
            invoke_query_api_pattern_method(method_name, *args, &block)
          rescue PatternNotFoundError => e
            if method_name.to_s[/\A[A-Z]/]
              api(method_name, *args, &block)
            else
              super
            end
          end
        end
      end
    end
  end
end
