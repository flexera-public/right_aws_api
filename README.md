
# AWS for Ruby

## Notice

The gem provides interface to AWS cloud services.

Maintained by the RightScale "Orange_team"

## Features

The gem supports next AWS services out of the box:

- {RightScale::CloudApi::AWS::AS::Manager      Auto Scaling (AS)}
- {RightScale::CloudApi::AWS::CF::Manager      Cloud Front (CF)}
- {RightScale::CloudApi::AWS::CFM::Manager     Cloud Formation (CFM)}
- {RightScale::CloudApi::AWS::CW::Manager      Cloud Watch (CW)}
- {RightScale::CloudApi::AWS::EB::Manager      Elastic Beanstalk (EB)}
- {RightScale::CloudApi::AWS::EC::Manager      Elasti Cache (EC)}
- {RightScale::CloudApi::AWS::EC2::Manager     Elastic Compute Cloud (EC2)}
- {RightScale::CloudApi::AWS::ELB::Manager     Elastic Load Balancing (ELB)}
- {RightScale::CloudApi::AWS::EMR::Manager     Elastic Map Reduce (EMR)}
- {RightScale::CloudApi::AWS::IAM::Manager     Identity and Access Management (IAM)}
- {RightScale::CloudApi::AWS::RDS::Manager     Relational Database Service (RDS)}
- {RightScale::CloudApi::AWS::Route53::Manager Route 53 (Route53)}
- {RightScale::CloudApi::AWS::S3::Manager      Simple Storage Service (S3)}
- {RightScale::CloudApi::AWS::SDB::Manager     Simple DB (SDB)}
- {RightScale::CloudApi::AWS::SNS::Manager     Simple Notification Service (SNS)}
- {RightScale::CloudApi::AWS::SQS::Manager     Simple Queue Service (SQS)}

And it is easy to add support for other.

(Plz refer to AWS docs (http://aws.amazon.com/documentation/) for API params and usage explanation)

## Basic usage

### Amazon Elastic Compute Cloud (EC2)

With this manager you do not need to worry aboutany new API call implementations.
If you know that EC2 supports a call and you know what params it accepts -
just call the method with those params.

#### Basics

```ruby
  require "right_aws_api"

  key      = ENV['AWS_ACCESS_KEY_ID']
  secret   = ENV['AWS_SECRET_ACCESS_KEY']
  endpoint = 'https://us-east-1.ec2.amazonaws.com'
  ec2      = RightScale::CloudApi::AWS::EC2::Manager.new(key, secret, endpoint)

  ec2.ThisCallMustBeSupportedByEc2('Param.1' => 'A', 'Param.2' => 'B')
```

#### EC2 Instances

```ruby
  require "right_aws_api"

  # Get a list of your instances
  ec2.DescribeInstances

  # Describe custom Instance(s)
  ec2.DescribeInstances('InstanceId' => "i-2ba7c640")
  ec2.DescribeInstances('InstanceId' => ["i-2ba7c640", "i-7db9101e"])

  # Describe Instances with filteringSame (another way, the result is the same):
  ec2.DescribeInstances(
    'Filter' => [
      {'Name'  => 'architecture',
       'Value' => 'i386'},
      {'Name'  => 'availability-zone',
       'Value' => [ 'us-east-1a', 'us-east-1d' ]},
      {'Name'  => 'instance-type',
       'Value' =>  'm1.small'} ]
  )

  # Run an new instance:
  ec2.RunInstances(
    'ImageId'            => 'ami-8ef607e7',
    'MinCount'           => 1,
    'MaxCount'           => 1,
    'KeyName'            => 'kd: alex',
    'UserData'           => RightScale::CloudApi::Utils::base64en('Hehehehe!!!!'),
    'InstanceType'       => 'c1.medium',
    'ClientToken'        => RightScale::CloudApi::Utils::generate_token,
    'SecurityGroupId'    => ['sg-f71a089e', 'sg-c71a08ae' ],
    'Placement+'         => {
       'AvailabilityZone' => 'us-east-1d',
       'Tenancy'          => 'default' },
    'BlockDeviceMapping' => [
      {'DeviceName' => '/dev/sdc',
       'Ebs'        => {
         'SnapshotId'          => 'snap-e40fd188',
         'VolumeSize'          => 3,
         'DeleteOnTermination' => true}} ]
  )

  # Terminate your instance:
  ec2.TerminateInstances("InstanceId" => ["i-67c87504", "i-67c87504"])
```

### Amazon Simple Storage Service (S3)

```ruby
  require "right_aws_api"

  key      = ENV['AWS_ACCESS_KEY_ID']
  secret   = ENV['AWS_SECRET_ACCESS_KEY']
  endpoint = 'https://s3.amazonaws.com'
  s3       = RightScale::CloudApi::AWS::S3::Manager::new(key, secret, endpoint)

  s3.ListBuckets
  s3.GetBucketAcl('Bucket' => 'my-lovely-bucket')
  s3.GetObject('Bucket' => 'my-lovely-bucket', 'Object' => 'fairies.txt')
```

### Amazon Simple Queue Service (SQS)

```ruby
  require "right_aws_api"

  key            = ENV['AWS_ACCESS_KEY_ID']
  secret         = ENV['AWS_SECRET_ACCESS_KEY']
  account_number = ENV['AWS_ACCOUNT_NUMBER']
  endpoint       = 'https://sqs.us-east-1.amazonaws.com'
  sqs            = RightScale::CloudApi::AWS::SQS::Manager.new(key, secret, account_number, endpoint)

  # List all queues
  sqs.ListQueues

  # Create a new one
  sqs.CreateQueue(
    'QueueName' => 'myCoolQueue',
    'Attribute' => [
       { 'Name'  => 'VisibilityTimeout',  'Value' => 40 },
       { 'Name'  => 'MaximumMessageSize', 'Value' => 2048 } ])

  # Send a message
  message = URI::escape('Woohoo!!!')
  sqs.SendMessage('myCoolQueue', 'MessageBody' => message)

  # Receive a message
  sqs.ReceiveMessage('myCoolQueue')

  # Kill the queue
  sqs.DeleteQueue('myCoolQueue')
```

## Dependencies

https://github.com/rightscale/right_cloud_api_base

## (c) RightScale
