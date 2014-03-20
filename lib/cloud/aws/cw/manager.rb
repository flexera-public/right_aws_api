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

      # CloudWatch namespace
      module CW
        
        # Amazon CloudWatch (CW) compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  cw = RightScale::CloudApi::AWS::CW::Manager::new(key, secret, 'https://monitoring.us-east-1.amazonaws.com')
        #
        #  # Get a list of valid metrics stored for the AWS account owner.
        #  cw.ListMetrics #=>
        #    {"ListMetricsResponse"=>
        #      {"@xmlns"=>"http://monitoring.amazonaws.com/doc/2010-08-01/",
        #       "ListMetricsResult"=>
        #        {"Metrics"=>
        #          {"member"=>
        #            [{"Dimensions"=>
        #               {"member"=>{"Name"=>"InstanceId", "Value"=>"i-29fc074d"}},
        #              "MetricName"=>"DiskReadOps",
        #              "Namespace"=>"AWS/EC2"},
        #             {"Dimensions"=>
        #               {"member"=>
        #                 {"Name"=>"QueueName",
        #                  "Value"=>"dano7_audit_queue_server_array_test"}},
        #              "MetricName"=>"ApproximateNumberOfMessagesDelayed",
        #              "Namespace"=>"AWS/SQS"},
        #             {"Dimensions"=>
        #               {"member"=>
        #                 {"Name"=>"QueueName",
        #                  "Value"=>"dano_input_queue_server_array_test"}},
        #              "MetricName"=>"ApproximateNumberOfMessagesNotVisible",
        #              "Namespace"=>"AWS/SQS"}]},
        #         "NextToken"=>
        #          "w9...xhCEA=="},
        #       "ResponseMetadata"=>{"RequestId"=>"bd188949-4f61-11e2-9a69-59e1411d80ca"}}}
        #
        # @example
        #  # Get alarms history.
        #  cw.DescribeAlarmHistory #=>
        #    {"DescribeAlarmHistoryResponse"=>
        #      {"@xmlns"=>"http://monitoring.amazonaws.com/doc/2010-08-01/",
        #       "DescribeAlarmHistoryResult"=>{"AlarmHistoryItems"=>nil},
        #       "ResponseMetadata"=>{"RequestId"=>"2f087a3b-4f62-11e2-b8d8-754622cf5638"}}}
        #
        #  # Get a history for the specified alarm.
        #  cw.DescribeAlarmHistory('AlarmName' => 'MyAlarm')
        #
        # @see ApiManager
        # @see http://docs.amazonwebservices.com/AmazonCloudWatch/latest/APIReference/Welcome.html
        #
        class Manager < AWS::Manager
        end


        # Amazon CloudWatch (CW) compatible manager (thread unsafe).
        #
        # @see Manager
        #
        class  ApiManager < AWS::ApiManager

          # Default API version for CloudWatch service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2010-08-01'

          error_pattern :abort_on_timeout,     :path     => /Action=(Put)/
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