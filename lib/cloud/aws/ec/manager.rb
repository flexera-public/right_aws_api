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

require "cloud/aws/base/manager"

module RightScale
  module CloudApi
    module AWS

      # ElastiCache namespace
      module EC
        
        # Amazon ElastiCache (EC) compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  eb = RightScale::CloudApi::AWS::EC::Manager::new(key, secret, 'https://elasticache.us-east-1.amazonaws.com')
        #
        #  # Get information about all provisioned Cache Clusters if no Cache Cluster identifier is specified, 
        #  # or about a specific Cache Cluster if a Cache Cluster identifier is supplied
        #  eb.DescribeCacheClusters #=>
        #    {"DescribeApplicationsResponse"=>
        #      {"@xmlns"=>"http://elasticbeanstalk.amazonaws.com/docs/2010-12-01/",
        #       "DescribeApplicationsResult"=>{"Applications"=>nil},
        #       "ResponseMetadata"=>{"RequestId"=>"b7c61b5a-4f69-11e2-a3d0-a772ddd49d31"}}}
        #
        # @example
        #  # Get a list of CacheSubnetGroup descriptions
        #  eb.DescribeCacheSubnetGroups #=> 
        #    {"DescribeCacheSubnetGroupsResponse"=>
        #      {"@xmlns"=>"http://elasticache.amazonaws.com/doc/2012-11-15/",
        #       "DescribeCacheSubnetGroupsResult"=>{"CacheSubnetGroups"=>nil},
        #       "ResponseMetadata"=>{"RequestId"=>"ae3546cb-4f6e-11e2-b196-0b589a77da67"}}}
        #
        # @see ApiManager
        # @see http://docs.aws.amazon.com/AmazonElastiCache/latest/APIReference/API_Operations.html
        #
        class Manager < AWS::Manager
        end

        # Amazon ElastiCache (EC) compatible manager (thread unsafe).
        #
        # @see Manager
        #
        class  ApiManager < AWS::ApiManager

          # Default API version for ElastiCache service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2012-11-15'

          error_pattern :abort_on_timeout,     :path     => /Action=(Create|Purchase)/
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