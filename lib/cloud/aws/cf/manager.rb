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
require "cloud/aws/cf/routines/request_signer"
require "cloud/aws/cf/wrappers/default"

module RightScale
  module CloudApi
    module AWS

      # Cloud Front namespace
      #
      # @api public
      #
      module CF

        # Amazon Cloud Front (CF) compatible manager (thread safe)
        #
        # @example
        #  require "right_aws_api"
        #
        #  cf = RightScale::CloudApi::AWS::CF::Manager::new(key, secret, 'https://cloudfront.amazonaws.com')
        #
        #  cf.GetDistributionList('MaxItems' => 2) #=>
        #    {"DistributionList"=>
        #      {"IsTruncated"=>"true",
        #       "NextMarker"=>"E20O0ZWO4WRF3I",
        #       "Marker"=>nil,
        #       "MaxItems"=>"2",
        #       "DistributionSummary"=>
        #        [{"Status"=>"Deployed",
        #          "Comment"=>"test",
        #          "Enabled"=>"true",
        #          "LastModifiedTime"=>"2008-10-23T15:17:24.447Z",
        #          "CNAME"=>["c1.test.com", "c2.test.com"],
        #          "Id"=>"E2FLHADADBK2P9",
        #          "DomainName"=>"d2kia27jveea52.cloudfront.net",
        #          "S3Origin"=>{"DNSName"=>"aws-test.s3.amazonaws.com"}},
        #         {"Status"=>"Deployed",
        #          "Comment"=>
        #           "Distribution created for the blog demo, can be deleted anytime.",
        #          "Enabled"=>"false",
        #          "LastModifiedTime"=>"2009-04-20T07:05:37.257Z",
        #          "CNAME"=>"blog-demo.rightscale.com",
        #          "Id"=>"E20O0ZWO4WRF3I",
        #          "DomainName"=>"dc5eg4un365fp.cloudfront.net",
        #          "S3Origin"=>{"DNSName"=>"aws-test.s3.amazonaws.com"}}],
        #       "@xmlns"=>"http://cloudfront.amazonaws.com/doc/2010-11-01/"}}
        #
        # @example
        #  cf.GetDistribution('DistributionId' => 'E2FLHADADBK2P9') #=> 
        #    {"Distribution"=>
        #        {"Status"=>"Deployed",
        #        "LastModifiedTime"=>"2008-10-23T15:17:24.447Z",
        #        "InProgressInvalidationBatches"=>"0",
        #        "Id"=>"E2FLHADADBK2P9",
        #        "DistributionConfig"=>
        #          {"Comment"=>"test",
        #          "Enabled"=>"true",
        #          "CallerReference"=>"200810231517246798821075",
        #          "CNAME"=>["c1.test.com", "c2.test.com"],
        #          "S3Origin"=>{"DNSName"=>"aws-test.s3.amazonaws.com"}},
        #        "DomainName"=>"d2kia27jveea52.cloudfront.net",
        #        "@xmlns"=>"http://cloudfront.amazonaws.com/doc/2010-11-01/"}}
        #
        # @see ApiManager
        # @see Wrapper::DEFAULT.extended Wrapper::DEFAULT.extended (click [View source])
        # @see http://docs.aws.amazon.com/AmazonCloudFront/latest/APIReference/Welcome.html
        #
        class Manager < CloudApi::Manager
        end

        # Amazon Cloud Front (CF) compatible manager (thread unsafe)
        #
        # @see Manager
        #
        class  ApiManager < CloudApi::ApiManager

          # CF Error
          class Error < CloudApi::Error
          end

          # Default API version for CloudFront service
          #
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2012-07-01'

          include Mixin::QueryApiPatterns

          set_routine CloudApi::RetryManager
          set_routine CloudApi::RequestInitializer
          set_routine AWS::CF::RequestSigner
          set_routine CloudApi::RequestGenerator
          set_routine CloudApi::ConnectionProxy
          set_routine CloudApi::ResponseAnalyzer
          set_routine CloudApi::ResponseParser
          set_routine CloudApi::ResultWrapper

          set :response_error_parser => Parser::AWS::ResponseErrorV2


          # Initializes Amazon CloudFront service manager
          #
          # @param [String] aws_access_key_id
          # @param [String] aws_secret_access_key
          # @param [String] endpoint
          # @param [Hash]   options
          #
          # @return [RightScale::CloudApi::AWS::CF::ApiManager]
          #
          # @example
          #   # see Manager class for example
          #
          # @see Manager
          #
          def initialize(aws_access_key_id, aws_secret_access_key, endpoint, options={})
            credentials = { :aws_access_key_id     => aws_access_key_id,
                            :aws_secret_access_key => aws_secret_access_key }
            super(credentials, endpoint, options)
          end


          # Makes an API call to AWS Cloud Front compatible cloud
          #
          # @param [String,Symbol] verb
          # @param [Objects] args
          #
          # @return [Object]
          #
          # @example
          #   api(verb,                      opts={})
          #   api(verb, 'distribution',      opts={})
          #   # Where opts may have next keys: :options, :headers, :params
          #   api(verb, 'distribution/path', opts={})
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