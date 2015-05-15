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

require "cloud/aws/base/helpers/utils"
require "cloud/aws/base/parsers/response_error"
require "cloud/aws/route53/domain/routines/request_signer"
require "cloud/aws/route53/domain/wrappers/default"

module RightScale
  module CloudApi
    module AWS

      # Route 53 namespace
      module Route53
        module Domain

          # Amazon Route 53 Domain compatible manager (thread safe).
          #
          #  Supported API calls:
          #  - using get, post, put, etc methods:
          #    - any API call for any API version
          #  - using predefined methods in wrappers/default.rb (only API version 20140515):
          #    - CheckDomainAvailability
          #    - DeleteTagsForDomain
          #    - DisableDomainAutoRenew
          #    - DisableDomainTransferLock
          #    - EnableDomainAutoRenew
          #    - EnableDomainTransferLock
          #    - GetDomainDetail
          #    - GetOperationDetail
          #    - ListDomains
          #    - ListOperations
          #    - ListTagsForDomain
          #    - RegisterDomain
          #    - RetrieveDomainAuthCode
          #    - TransferDomain
          #    - UpdateDomainContact
          #    - UpdateDomainContactPrivacy
          #    - UpdateDomainNameservers
          #    - UpdateTagsForDomains
          #
          # @example
          #  require "right_aws_api"
          #
          #  domain = RightScale::CloudApi::AWS::Route53::Domain::Manager::new(
          #    ENV['AWS_ACCESS_KEY_ID'],
          #    ENV['AWS_SECRET_ACCESS_KEY'],
          #    'https://route53domains.us-east-1.amazonaws.com/'
          #  )
          #
          #  # Using http verbs:
          #  domain.post('',
          #    :headers => {
          #      'x-amz-target' => 'Route53Domains_v20140515.CheckDomainAvailability',
          #      'content-type' => 'application/x-amz-json-1.1'
          #    },
          #    :body => { 'DomainName' => 'domain-name.com' }
          #  ) #=>
          #    {"Availability":"UNAVAILABLE"}
          #
          #  # Using predefined methods:
          #  domain.CheckDomainAvailability("DomainName" => "foo-bar-weird.com") #=>
          #    {"Availability"=>"AVAILABLE"}
          #
          # @see ApiManager
          # @see Wrapper::DEFAULT.extended Wrapper::DEFAULT.extended (click [View source])
          # @see http://docs.aws.amazon.com/Route53/latest/APIReference/Welcome.html
          #
          class Manager < CloudApi::Manager
          end


          # Amazon Route 53 (Route) compatible manager (thread safe)
          #
          # @see Manager
          #
          class  ApiManager < CloudApi::ApiManager

            # RequestSigner Error
            class Error < CloudApi::Error
            end

            # Default API version for Route53 service.
            # To override the API version use :api_version key when instantiating a manager.
            #
            DEFAULT_API_VERSION = '20140515'

            include Mixin::QueryApiPatterns

            set_routine CloudApi::RetryManager
            set_routine CloudApi::RequestInitializer
            set_routine AWS::Route53::Domain::RequestSigner
            set_routine CloudApi::RequestGenerator
            set_routine CloudApi::ConnectionProxy
            set_routine CloudApi::ResponseAnalyzer
            set_routine CloudApi::ResponseParser
            set_routine CloudApi::ResultWrapper

            set :response_error_parser => Parser::AWS::ResponseErrorV2


            # Constructor
            #
            # @param [String] aws_access_key_id
            # @param [String] aws_secret_access_key
            # @param [String] endpoint
            # @param [Hash] options
            #
            # @example
            #   # see Manager class usage
            #
            # @see Manager
            #
            def initialize(aws_access_key_id, aws_secret_access_key, endpoint, options={})
              credentials = { :aws_access_key_id     => aws_access_key_id,
                              :aws_secret_access_key => aws_secret_access_key }
              super(credentials, endpoint, options)
            end


            # Makes an API call to AWS::Route53 compatible cloud
            #
            # @param [String,Symbol] verb
            # @param [Objects] args
            #
            # @return [Object]
            #
            # @example
            #   api(verb,         opts={})
            #   # Where opts may have next keys: :options, :headers, :params
            #   api(verb, 'path', opts={})
            #
            def api(verb, *args, &block)
              relative_path = args.first.is_a?(String) ? args.shift : ''
              opts          = args.shift || {}
              raise Error::new("Opts must be Hash not #{opts.class.name}") unless opts.is_a?(Hash)
              process_api_request(verb, relative_path, opts, &block)
            end

          end

        end
      end
    end
  end
end