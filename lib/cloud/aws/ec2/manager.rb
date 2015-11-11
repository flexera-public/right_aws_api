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

      # Elastic Compute Cloud namespace
      module EC2
        # Amazon Elastic Compute Cloud (EC2) compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  # Create a manager to access EC2.
        #  ec2 = RightScale::CloudApi::AWS::EC2::Manager::new(key, secret, 'https://ec2.us-east-1.amazonaws.com')
        #
        #  ec2.ThisCallMustBeSupportedByEc2('Param.1' => 'A', 'Param.2' => 'B')
        #
        # If there is a new API version just pass it to the manager and woohoo!
        #
        # @example
        #  ec2 = RightScale::CloudApi::AWS::EC2::new(key, secret, 'https://ec2.us-east-1.amazonaws.com',  :api_version => "2010-08-31" )
        #  ec2.DescribeInternetGateways # => Gateways list
        #
        #  ec2 = RightScale::CloudApi::AWS::EC2::new(key, secret, 'https://ec2.us-east-1.amazonaws.com',  :api_version => "2011-05-15" )
        #  ec2.DescribeInternetGateways # => Exception
        #
        #  # Or even pass a different API version when making a call!
        #  ec2 = RightScale::CloudApi::AWS::EC2::new(key, secret, 'https://ec2.us-east-1.amazonaws.com',  :api_version => "2010-08-31" )
        #  ec2.DescribeInternetGateways("InternetGatewayId"=>"igw-55660000") # => Exception
        #  ec2.DescribeInternetGateways("InternetGatewayId"=>"igw-55660000", :options => { :api_version => "2011-05-15" }) #=> Gateway data
        #
        # @example
        #  # Get a list of your instances
        #  ec2.DescribeInstances
        #
        #  # Describe custom Instance(s)
        #  ec2.DescribeInstances('InstanceId'   => "i-2ba7c640")
        #  ec2.DescribeInstances('InstanceId.1' => "i-2ba7c640",
        #                        'InstanceId.2' => "i-7db9101e")
        #  ec2.DescribeInstances('InstanceId'   => ["i-2ba7c640", "i-7db9101e"])
        #
        # @example
        #  # Describe Instances with filtering:
        #  ec2.DescribeInstances( 'Filter.1.Name'    => 'architecture',
        #                         'Filter.1.Value'   => 'i386',
        #                         'Filter.2.Name'    => 'availability-zone',
        #                         'Filter.2.Value.1' => 'us-east-1a',
        #                         'Filter.2.Value.2' => 'us-east-1d',
        #                         'Filter.3.Name'    => 'instance-type',
        #                         'Filter.3.Value'   => 'm1.small')
        #
        #  # (produces the same result as the request above)
        #  ec2.DescribeInstances( 'Filter' => [{ 'Name'  => 'architecture',      'Value' => 'i386'},
        #                                      { 'Name'  => 'availability-zone', 'Value' => [ 'us-east-1a', 'us-east-1d' ]},
        #                                      { 'Name'  => 'instance-type',     'Value' =>  'm1.small'}] )
        #
        # @example
        #  # Run an instance:
        #  ec2.RunInstances( 'ImageId'      => 'ami-8ef607e7',
        #                    'MinCount'     => 1,
        #                    'MaxCount'     => 1,
        #                    'KeyName'      => 'kd: alex',
        #                    'UserData'     => RightScale::CloudApi::Utils::base64en('Hehehehe!!!!'),
        #                    'InstanceType' => 'c1.medium',
        #                    'ClientToken'  => RightScale::CloudApi::Utils::generate_token,
        #                    'SecurityGroupId.1' => 'sg-f71a089e',
        #                    'SecurityGroupId.2' => 'sg-c71a08ae',
        #                    'Placement.AvailabilityZone' => 'us-east-1d',
        #                    'Placement.Tenancy'          => 'default',
        #                    'BlockDeviceMapping.1.DeviceName'              => '/dev/sdb',
        #                    'BlockDeviceMapping.1.Ebs.SnapshotId'          => 'snap-f338e591',
        #                    'BlockDeviceMapping.1.Ebs.VolumeSize'          => 2,
        #                    'BlockDeviceMapping.1.Ebs.DeleteOnTermination' => true,
        #                    'BlockDeviceMapping.2.DeviceName'              => '/dev/sdc',
        #                    'BlockDeviceMapping.2.Ebs.SnapshotId'          => 'snap-e40fd188',
        #                    'BlockDeviceMapping.2.Ebs.VolumeSize'          => 3,
        #                    'BlockDeviceMapping.2.Ebs.DeleteOnTermination' => true ) #=> see below
        #
        #  # or run it like this:
        #  ec2.RunInstances(
        #    'ImageId'               => 'ami-8ef607e7',
        #    'MinCount'              => 1,
        #    'MaxCount'              => 1,
        #    'KeyName'               => 'kd: alex',
        #    'UserData'              => RightScale::CloudApi::Utils::base64en('Hehehehe!!!!'),
        #    'InstanceType'          => 'c1.medium',
        #    'ClientToken'           => RightScale::CloudApi::Utils::generate_token,
        #    'SecurityGroupId'       => [ 'sg-f71a089e', 'sg-c71a08ae' ],
        #    'Placement+'            => { 'AvailabilityZone' => 'us-east-1d',
        #                                 'Tenancy'          => 'default'},
        #    'BlockDeviceMapping' => [ { 'DeviceName'              => '/dev/sdb',
        #                                'Ebs.SnapshotId'          => 'snap-f338e591',         # way #1
        #                                'Ebs.VolumeSize'          => 2,
        #                                'Ebs.DeleteOnTermination' => true },
        #                              { 'DeviceName'              => '/dev/sdc',
        #                                'Ebs' => { 'SnapshotId'          => 'snap-e40fd188',  # way #2
        #                                           'VolumeSize'          => 3,
        #                                           'DeleteOnTermination' => true } } ] ) #=>
        #    {"RunInstancesResponse"=>
        #      {"reservationId"=>"r-c8ca9ca6",
        #       "requestId"=>"04632453-adbf-460b-b101-1d9c11df9a60",
        #       "groupSet"=>
        #        {"item"=>
        #          [{"groupName"=>"kd-hehehe", "groupId"=>"sg-f71a089e"},
        #           {"groupName"=>"kd-hehehe-1", "groupId"=>"sg-c71a08ae"}]},
        #       "instancesSet"=>
        #        {"item"=>
        #          {"keyName"=>"kd: alex",
        #           "stateReason"=>{"code"=>"pending", "message"=>"pending"},
        #           "hypervisor"=>"xen",
        #           "ramdiskId"=>"ari-a51cf9cc",
        #           "blockDeviceMapping"=>nil,
        #           "productCodes"=>nil,
        #           "groupSet"=>
        #            {"item"=>
        #              [{"groupName"=>"kd-hehehe", "groupId"=>"sg-f71a089e"},
        #               {"groupName"=>"kd-hehehe-1", "groupId"=>"sg-c71a08ae"}]},
        #           "clientToken"=>"5d8248d4d6653a1b5127222b7902854a93f7",
        #           "imageId"=>"ami-8ef607e7",
        #           "amiLaunchIndex"=>"0",
        #           "launchTime"=>"2011-11-07T19:45:34.000Z",
        #           "kernelId"=>"aki-a71cf9ce",
        #           "reason"=>nil,
        #           "instanceType"=>"c1.medium",
        #           "instanceId"=>"i-67c87504",
        #           "placement"=>
        #            {"groupName"=>nil,
        #             "tenancy"=>"default",
        #             "availabilityZone"=>"us-east-1d"},
        #           "rootDeviceType"=>"ebs",
        #           "rootDeviceName"=>"/dev/sda1",
        #           "privateDnsName"=>nil,
        #           "dnsName"=>nil,
        #           "instanceState"=>{"name"=>"pending", "code"=>"0"},
        #           "monitoring"=>{"state"=>"disabled"},
        #           "virtualizationType"=>"paravirtual"}},
        #       "ownerId"=>"826693181925",
        #       "@xmlns"=>"http://ec2.amazonaws.com/doc/2011-07-15/"}}
        #
        # @example
        #  # Terminate your instance:
        #  ec2.TerminateInstances( "InstanceId" => "i-67c87504") #=>
        #    {
        #      "TerminateInstancesResponse" => {
        #        "@xmlns"       => "http://ec2.amazonaws.com/doc/2011-07-15/",
        #        "instancesSet" => {
        #          "item" => {
        #            "currentState"  => {
        #              "code" => "48",
        #              "name" => "terminated"
        #            },
        #            "instanceId"    => "i-67c87504",
        #            "previousState" => {
        #              "code" => "48",
        #              "name" => "terminated"
        #            }
        #          }
        #        },
        #        "requestId"    => "bf966c52-ee28-4eb2-af1c-dceff7bff231"
        #      }
        #    }
        #
        # @see ApiManager
        # @see http://docs.aws.amazon.com/AWSEC2/latest/APIReference
        #
        class Manager < AWS::Manager
        end


        # Amazon Elastic Compute Cloud (EC2) compatible manager (thread unsafe).
        #
        # @see Manager
        #
        class  ApiManager < AWS::ApiManager

          # Default API version for EC2 service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2013-02-01'

          error_pattern :abort_on_timeout,     :path     => /Action=(Run|Create|Purchase)/
          error_pattern :abort,                :response => /InsufficientInstanceCapacity/i
          error_pattern :retry,                :response => /InternalError|Unavailable|Internal Server Error/i
          error_pattern :retry,                :response => /Please try again|no response from|Request limit exceeded/i
          error_pattern :disconnect_and_abort, :code     => /5..|403|408/
          error_pattern :disconnect_and_abort, :code     => /4../, :if => Proc.new{ |opts| rand(100) < 10 }

          cache_pattern :verb  => /get|post/,
                        :path  => /Action=Describe/,
                        :if    => Proc::new{ |o| (o[:params].keys - COMMON_QUERY_PARAMS)._blank? },
                        :key   => Proc::new{ |o| o[:params]['Action'] },
                        :sign  => Proc::new{ |o| o[:response].body.to_s.sub(%r{<requestId>.+?</requestId>}i,'') }
        end
      end

    end
  end
end
