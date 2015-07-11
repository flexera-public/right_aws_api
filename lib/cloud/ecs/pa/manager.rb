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

require "cloud/ecs/pa/routines/request_signer"
require "cloud/ecs/pa/parsers/response_error"

module RightScale
  module CloudApi

    # ECS (ECommerceService) namespace
    module ECS

      module PA

        # Product Advertising API (PA) compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  # Create a manager to access Product Advertising API.
        #  paa = RightScale::CloudApi::ECS::PA::Manager.new(key, secret, 'https://webservices.amazon.com')
        #
        #  paa.ThisCallMustBeSupportedByPA('Param.1' => 'A', 'Param.2' => 'B') #=> Hash
        #
        # @example
        #  paa.ItemSearch(
        #    'AssociateTag'  => 'weird-tag',
        #    'BrowseNode'    => 2625374011,
        #    'MaximumPrice'  => 2000,
        #    'MinimumPrice'  => 2000,
        #    'ResponseGroup' => 'SalesRank',
        #    'SearchIndex'   => 'DVD',
        #    'Sort'          => 'salesrank',
        #   )  #=>
        #      {"ItemSearchResponse"=>
        #        {"@xmlns"=>"http://webservices.amazon.com/AWSECommerceService/2013-08-01",
        #         "OperationRequest"=>
        #          {"HTTPHeaders"=>{"Header"=>{"@Name"=>"UserAgent", "@Value"=>"Ruby"}},
        #           "RequestId"=>"a21817e1-f828-4a80-8b6a-c27e320b92e2",
        #           "Arguments"=>
        #            {"Argument"=> ..... }}}
        #
        # @example
        #  paa.ItemLookup(
        #    'AssociateTag'  => 'weird-tag',
        #    'IdType'        => 'ASIN',
        #    'ItemId'        => 'B00TRAO8HK',
        #    'ResponseGroup' => 'OfferSummary',
        #  ) #=>
        #      {"ItemLookupResponse"=>
        #        {"@xmlns"=>"http://webservices.amazon.com/AWSECommerceService/2013-08-01",
        #         "OperationRequest"=>
        #          {"HTTPHeaders"=>{"Header"=>{"@Name"=>"UserAgent", "@Value"=>"Ruby"}},
        #           "RequestId"=>"1c199f5d-3794-40b3-9fc4-33316010d130",
        #           "Arguments"=> { ... },
        #         "Items"=>
        #          {"Request"=> { ... },
        #           "Item"=>
        #            {"ASIN"=>"B00TRAO8HK",
        #             "OfferSummary"=>
        #              {"LowestNewPrice"=>
        #                {"Amount"=>"2000",
        #                 "CurrencyCode"=>"USD",
        #                 "FormattedPrice"=>"$20.00"},
        #               "LowestUsedPrice"=>
        #                {"Amount"=>"2654",
        #                 "CurrencyCode"=>"USD",
        #                 "FormattedPrice"=>"$26.54"},
        #               "TotalNew"=>"23",
        #               "TotalUsed"=>"2",
        #               "TotalCollectible"=>"0",
        #               "TotalRefurbished"=>"0"}}}}}
        #
        # If there is a new API version available just pass it to the manager!
        #
        # @example
        #  paa = RightScale::CloudApi::ECS::PA::Manager.new(key, secret, 'https://webservices.amazon.com', :api_version => "2021-12-31")
        #
        # @see ApiManager
        # @see http://docs.aws.amazon.com/AWSECommerceService/latest/DG/Welcome.html
        #
        class Manager < CloudApi::Manager
        end

        # Thread un-safe parent class for almost all the AWS services.
        class ApiManager < AWS::ApiManager

          DEFAULT_API_VERSION = '2013-08-01'

          set_routine RetryManager
          set_routine RequestInitializer
          set_routine ECS::PA::RequestSigner
          set_routine RequestGenerator
          set_routine RequestAnalyzer
          set_routine ConnectionProxy
          set_routine ResponseAnalyzer
          set_routine CacheValidator
          set_routine ResponseParser
          set_routine ResultWrapper

          set :response_error_parser => Parser::ECS::ResponseError

          def api(action, params={}, &block)
            params['Operation'] ||= action.to_s._snake_case._camelize
            opts = {}
            verb           = params.delete(:verb) || :post
            opts[:body]    = params.delete(:body)
            opts[:headers] = params.delete(:headers) || {}
            opts[:options] = params.delete(:options) || {}
            opts[:params]  = parametrize(params)
            process_api_request(verb, 'onca/xml', opts, &block)
          end

        end
      end
    end
  end
end
