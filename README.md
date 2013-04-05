The gem provides interface to AWS cloud services.

Private Repo, not customer facing.

Maintained by the RightScale "Orange_team"

For supported services see "./cloud/aws" folder.

AWS EC2 service usage example:

    # Amazon Elastic Compute Cloud (EC2) compatible manager.
    #
    # This manager does not need to worry about new API call implementations.
    # If you know that EC2 supports a call and you know what params it accepts -
    # call the method with those params.
    #
    # Just refer to the AWS docs ({http://aws.amazon.com/documentation/}) and that's it!
    #
    # @example
    #  require "right_aws_api"
    #  require "aws/ec2"
    #
    #  # Create a manager to access EC2.
    #  ec2 = RightScale::CloudApi::AWS::EC2::Manager::new(key, secret, 'https://us-east-1.ec2.amazonaws.com')
    #  
    #  ec2.ThisCallMustBeSupportedByEc2('Param.1' => 'A', 'Param.2' => 'B')
    #
    # If there is a new API version just pass it to the manager and woohoo!
    #
    # @example
    #  ec2 = RightScale::CloudApi::AWS::EC2::new(key, secret, 'https://us-east-1.ec2.amazonaws.com',  :api_version => "2010-08-31" )
    #  ec2.DescribeInternetGateways # => Gateways list
    #
    #  ec2 = RightScale::CloudApi::AWS::EC2::new(key, secret, 'https://us-east-1.ec2.amazonaws.com',  :api_version => "2011-05-15" )
    #  ec2.DescribeInternetGateways # => Exception
    #  
    #  # Or even pass a different API version when making a call!
    #  ec2 = RightScale::CloudApi::AWS::EC2::new(key, secret, 'https://us-east-1.ec2.amazonaws.com',  :api_version => "2010-08-31" )
    #  ec2.DescribeInternetGateways # => Exception
    #  ec2.DescribeInternetGateways({}, :options => { :api_version => "2011-05-15" }) #=> Gateways list
    #   
    # @example
    #  # Get a list of your instances
    #  ec2.DescribeInstances #=>
    #    {
    #      "DescribeInstancesResponse" => {
    #        "@xmlns"         => "http://ec2.amazonaws.com/doc/2011-07-15/",
    #        "requestId"      => "4f90e687-2248-4d97-9858-f337b88a3864",
    #        "reservationSet" => {
    #          "item" => [
    #             {
    #              "groupSet"      => {
    #                "item" => {
    #                  "groupId"   => "sg-a0b85dc9",
    #                  "groupName" => "default"
    #                }
    #              },
    #              "instancesSet"  => {
    #                "item" => {
    #                  "amiLaunchIndex"     => "0",
    #                  "architecture"       => "i386",
    #                  "blockDeviceMapping" => nil,
    #                  "clientToken"        => nil,
    #                  "dnsName"            => nil, ...
    #    }
    #
    # @example
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