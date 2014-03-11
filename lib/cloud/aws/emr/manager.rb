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

      # ElasticMapReduce namespace
      module EMR
        
        # Amazon ElasticMapReduce (EMR) compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  emr = RightScale::CloudApi::AWS::EMR::Manager::new(key, secret, 'https://elasticmapreduce.us-east-1.amazonaws.com')
        #
        #  # Get a list of job flows that match all of the supplied parameters
        #  emr.DescribeJobFlows #=>
        #    {"DescribeJobFlowsResponse"=>
        #      {"@xmlns"=>"http://elasticmapreduce.amazonaws.com/doc/2009-03-31",
        #       "DescribeJobFlowsResult"=>{"JobFlows"=>nil},
        #       "ResponseMetadata"=>{"RequestId"=>"962fa6c0-4f71-11e2-9237-6da8e8d0164c"}}}
        #
        # @example
        #  # Get a job by ID
        #  emr.DescribeJobFlows('JobFlowIds.member' => 'j-3UN6WX5RRO2AG')
        #
        # @see ApiManager
        # @see http://docs.aws.amazon.com/ElasticMapReduce/latest/API/API_Operations.html
        #
        class Manager < AWS::Manager
        end


        # Amazon ElasticMapReduce (EMR) compatible manager (thread unsafe).
        #
        # @see Manager
        #
        class  ApiManager < AWS::ApiManager

          # Default API version for ElasticMapReduce service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2009-03-31'

          error_pattern :abort_on_timeout,     :path     => /Action=(Run)/
          error_pattern :retry,                :response => /InternalError|Unavailable/i
          error_pattern :disconnect_and_abort, :code     => /5..|403|408/
          error_pattern :disconnect_and_abort, :code     => /4../, :if => Proc.new{ |opts| rand(100) < 10 }

          set :response_error_parser => Parser::AWS::ResponseErrorV2
          
          cache_pattern :verb  => /get|post/,
                        :path  => /Action=List/,
                        :if    => Proc::new{ |o| (o[:params].keys - COMMON_QUERY_PARAMS)._blank? },
                        :key   => Proc::new{ |o| o[:params]['Action'] },
                        :sign  => Proc::new{ |o| o[:response].body.to_s.sub(%r{<RequestId>.+?</RequestId>}i,'') }
        end
      end
      
    end
  end
end