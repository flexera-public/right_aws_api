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

      module AS
        
        # Amazon AutoScaling (AS) compatible manager.
        #
        # @example
        #  require "right_aws_api"
        #  require "aws/as"
        #
        #  # Create a manager to access Auto Scaling.
        #  as = RightScale::CloudApi::AWS::AS::Manager::new(key, secret, 'https://autoscaling.us-east-1.amazonaws.com')
        #
        #  # Get a description of each Auto Scaling instance in the InstanceIds list.
        #  as.DescribeAutoScalingInstances #=>
        #    {"DescribeAutoScalingGroupsResponse"=>
        #      {"@xmlns"=>"http://autoscaling.amazonaws.com/doc/2011-01-01/",
        #       "DescribeAutoScalingGroupsResult"=>
        #        {"AutoScalingGroups"=>
        #          {"member"=>
        #            {"SuspendedProcesses"=>nil,
        #             "Tags"=>nil,
        #             "AutoScalingGroupName"=>"CentOS.5.1-c-array",
        #             "HealthCheckType"=>"EC2",
        #             "CreatedTime"=>"2009-05-28T09:31:21.133Z",
        #             "EnabledMetrics"=>nil,
        #             "LaunchConfigurationName"=>"CentOS.5.1-c",
        #             "Instances"=>nil,
        #             "DesiredCapacity"=>"0",
        #             "AvailabilityZones"=>{"member"=>"us-east-1a"},
        #             "LoadBalancerNames"=>nil,
        #             "MinSize"=>"0",
        #             "VPCZoneIdentifier"=>nil,
        #             "HealthCheckGracePeriod"=>"0",
        #             "DefaultCooldown"=>"0",
        #             "AutoScalingGroupARN"=>
        #              "arn:aws:autoscaling:us-east-1:82...25:autoScalingGroup:47..5f-0d65-46cb-8a0c-0..000:autoScalingGroupName/CentOS.5.1-c-array",
        #             "TerminationPolicies"=>{"member"=>"Default"},
        #             "MaxSize"=>"3"}}},
        #       "ResponseMetadata"=>{"RequestId"=>"04022bd4-4f5d-11e2-b437-318e12cd4660"}}}
        #
        # @example
        #  # Get only records you need:
        #  as.DescribeAutoScalingInstances( 'AutoScalingGroupNames.member' => ["CentOS.5.1-c-array", "CentOS.5.2-d-array"])
        #
        # @example
        #  # Set the max number of records to bre returned:
        #  as.DescribeAutoScalingInstances('MaxRecords' => 3)
        #
        # @example
        #  # Create  a new Auto Scaling group
        #  as.CreateAutoScalingGroup('AutoScalingGroupName' => 'my-test-asgroup',
        #                            'DesiredCapacity' => 5,
        #                            'PlacementGroup' => 'my-cool-group')
        #
        # @see http://docs.amazonwebservices.com/AutoScaling/latest/APIReference/API_Operations.html
        #
        class Manager < AWS::Manager
        end

        class  ApiManager < AWS::ApiManager

          # Default API version for AutoScaling service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2011-01-01'

          error_pattern :abort_on_timeout,     :path     => /Action=(Create)/
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