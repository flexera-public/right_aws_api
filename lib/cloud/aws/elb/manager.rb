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

      # Elastic Load Balancing namespace
      module ELB
        
        # Amazon Elastic Load Balancing (ELB) compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  elb = RightScale::CloudApi::AWS::ELB::Manager::new(key, secret, 'https://elasticloadbalancing.amazonaws.com')
        #
        #  # List Load Balancers
        #  elb.DescribeLoadBalancers #=>
        #    {"DescribeLoadBalancersResponse"=>
        #      {"@xmlns"=>"http://elasticloadbalancing.amazonaws.com/doc/2011-11-15/",
        #       "DescribeLoadBalancersResult"=>
        #        {"LoadBalancerDescriptions"=>
        #          {"member"=>
        #            [{"SecurityGroups"=>nil,
        #              "CreatedTime"=>"2011-05-20T00:07:57.390Z",
        #              "LoadBalancerName"=>"test",
        #              "HealthCheck"=>
        #               {"Interval"=>"30",
        #                "Target"=>"TCP:80",
        #                "HealthyThreshold"=>"10",
        #                "Timeout"=>"5",
        #                "UnhealthyThreshold"=>"2"},
        #              "ListenerDescriptions"=>
        #               {"member"=>
        #                 {"PolicyNames"=>nil,
        #                  "Listener"=>
        #                   {"Protocol"=>"HTTP",
        #                    "LoadBalancerPort"=>"80",
        #                    "InstanceProtocol"=>"HTTP",
        #                    "InstancePort"=>"80"}}},
        #              "Instances"=>nil,
        #              "Policies"=>
        #               {"AppCookieStickinessPolicies"=>nil,
        #                "OtherPolicies"=>nil,
        #                "LBCookieStickinessPolicies"=>nil},
        #              "AvailabilityZones"=>
        #               {"member"=>
        #                 ["us-east-1c", "us-east-1b", "us-east-1a", "us-east-1d"]},
        #              "CanonicalHostedZoneName"=>
        #               "test-1900221105.us-east-1.elb.amazonaws.com",
        #              "CanonicalHostedZoneNameID"=>"Z3DZXE0Q79N41H",
        #              "SourceSecurityGroup"=>
        #               {"OwnerAlias"=>"amazon-elb", "GroupName"=>"amazon-elb-sg"},
        #              "DNSName"=>"test-1900221105.us-east-1.elb.amazonaws.com",
        #              "BackendServerDescriptions"=>nil,
        #              "Subnets"=>nil}]}},
        #       "ResponseMetadata"=>{"RequestId"=>"a96cfe8c-4f70-11e2-a887-0189db71cd82"}}}
        #
        # @example
        #  # Delete a Load Balancer
        #  elb.DeleteLoadBalancer('LoadBalancerName' => 'MyLoadBalancere')
        #
        # @see ApiManager
        # @see http://docs.amazonwebservices.com/ElasticLoadBalancing/latest/APIReference/API_Operations.html
        #
        class Manager < AWS::Manager
        end

        # Amazon Elastic Load Balancing (ELB) compatible manager (thread unsafe).
        #
        # @see Manager
        #
        class  ApiManager < AWS::ApiManager

          # Default API version for ELB service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = ' 2012-06-01'

          error_pattern :abort_on_timeout,     :path     => /Action=(Create)/
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