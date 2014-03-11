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
require "cloud/aws/base/parsers/response_error"
require "cloud/aws/route53/routines/request_signer"
require "cloud/aws/route53/wrappers/default"

module RightScale
  module CloudApi
    module AWS

      # Route 53 namespace
      module Route53

        # Amazon Route 53 (Route53) compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  r53 = RightScale::CloudApi::AWS::Route53::Manager::new(
        #    ENV['AWS_ACCESS_KEY_ID'],
        #    ENV['AWS_SECRET_ACCESS_KEY'],
        #    'https://route53.amazonaws.com'
        #    )
        #
        #  r53.ListHostedZones #=> 
        #    {"ListHostedZonesResponse"=>
        #      {"IsTruncated"=>"false",
        #       "HostedZones"=>
        #        {"HostedZone"=>
        #          {"Name"=>"aws.rightscale.com.",
        #           "CallerReference"=>"RightScaleTest",
        #           "Config"=>{"Comment"=>"This is RightScale test hosted zone."},
        #           "Id"=>"/hostedzone/Z3AINKOIEY1X3X"}},
        #       "MaxItems"=>"100",
        #       "@xmlns"=>"https://route53.amazonaws.com/doc/2011-05-05/"}}
        #
        #
        # @example
        #  r53.ListResourceRecordSets #=>        
        #    {"ListResourceRecordSetsResponse"=>
        #      {"IsTruncated"=>"false",
        #       "MaxItems"=>"100",
        #       "@xmlns"=>"https://route53.amazonaws.com/doc/2011-05-05/",
        #       "ResourceRecordSets"=>
        #        {"ResourceRecordSet"=>
        #          [{"ResourceRecords"=>
        #             {"ResourceRecord"=>
        #               [{"Value"=>"ns-671.awsdns-19.net."},
        #                {"Value"=>"ns-1057.awsdns-04.org."},
        #                {"Value"=>"ns-1885.awsdns-43.co.uk."},
        #                {"Value"=>"ns-438.awsdns-54.com."}]},
        #            "TTL"=>"172800",
        #            "Name"=>"aws.rightscale.com.",
        #            "Type"=>"NS"},
        #           {"ResourceRecords"=>
        #             {"ResourceRecord"=>
        #               {"Value"=>
        #                 "ns-671.awsdns-19.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"}},
        #            "TTL"=>"1000",
        #            "Name"=>"aws.rightscale.com.",
        #            "Type"=>"SOA"},
        #           {"ResourceRecords"=>{"ResourceRecord"=>{"Value"=>"10.244.154.211"}},
        #            "TTL"=>"60",
        #            "Name"=>"test.aws.rightscale.com.",
        #            "Type"=>"A"},
        #           {"ResourceRecords"=>{"ResourceRecord"=>{"Value"=>"10.194.215.64"}},
        #            "TTL"=>"60",
        #            "Name"=>"test1.aws.rightscale.com.",
        #            "Type"=>"A"},
        #           {"ResourceRecords"=>{"ResourceRecord"=>{"Value"=>"10.136.127.175"}},
        #            "TTL"=>"60",
        #            "Name"=>"testslave9.aws.rightscale.com.",
        #            "Type"=>"A"}]}}}
        #
        # @see Manager
        # @see Wrapper::DEFAULT.extended Wrapper::DEFAULT.extended (click [View source])
        # @see http://docs.aws.amazon.com/Route53/latest/APIReference/Welcome.html
        #
        class Manager < CloudApi::Manager
        end


        # Amazon Route 53 (Route53) compatible manager (thread safe).
        #
        # @see Manager
        #
        class  ApiManager < CloudApi::ApiManager
          class Error < CloudApi::Error
          end
          
          # Default API version for Route53 service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2011-05-05'

          include Mixin::QueryApiPatterns

          set_routine CloudApi::RetryManager
          set_routine CloudApi::RequestInitializer
          set_routine AWS::Route53::RequestSigner
          set_routine CloudApi::RequestGenerator
          set_routine CloudApi::ConnectionProxy
          set_routine CloudApi::ResponseAnalyzer
          set_routine CloudApi::ResponseParser
          set_routine CloudApi::ResultWrapper

          set :response_error_parser => Parser::AWS::ResponseErrorV2

          def initialize(aws_access_key_id, aws_secret_access_key, endpoint, options={})
            credentials = { :aws_access_key_id     => aws_access_key_id,
                            :aws_secret_access_key => aws_secret_access_key }
            super(credentials, endpoint, options)
          end

          # Make an API call to AWS::Route53 compatible cloud.
          # 
          # opts: [:options, :headers, :params, :body]
          # body: String, IO, Nil.
          #
          # Usage: api(verb,         opts={})
          #        api(verb, 'path', opts={})
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