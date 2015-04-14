# AWS (Amazon Web Services) library for Ruby

This gem provides access to many AWS cloud services.
Unlike many other AWS libaries this gem is a very thin adaptation layer over the AWS APIs.
It is highly meta-programmed and exposes the exact AWS API calls with the
exact AWS parameters. There are two big benefits to this approach: you don't have to translate betwen the
AWS docs and the library in order to figure out what to do, and there's nothing in the AWS APIs you can't
call through the library. The library doesn't even need to be updated when AWS introduces new API features.
The downside to this approach is that when things don't work it's sometimes more difficult to figure out
what's happening... Another downside is that method names and parameter names follow the AWS API spec and
thereby run against Ruby conventions.

If you encounter problems please open a github issue.

## Docs

For some getting-started info see further down but for detailed docs see
http://rightscale.github.io/right_aws_api/frames.html#!file.README.html

## Features

The gem supports the following AWS services out of the box:

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

And it is easy to add support for other. You will need to refer to
the AWS docs (http://aws.amazon.com/documentation/) for all the API params and usage explanations.

## Basic usage

### Amazon Elastic Compute Cloud (EC2)

This library supports all existing and future EC2 API calls. If you know that EC2 supports a
call and you know what params it accepts - just call the method with those params.

#### Basics

```ruby
  require "right_aws_api"

  key      = ENV['AWS_ACCESS_KEY_ID']
  secret   = ENV['AWS_SECRET_ACCESS_KEY']
  endpoint = 'https://ec2.us-east-1.amazonaws.com'
  ec2      = RightScale::CloudApi::AWS::EC2::Manager.new(key, secret, endpoint)

  ec2.ThisCallMustBeSupportedByEc2('Param.1' => 'A', 'Param.2' => 'B')
```

#### EC2 Instances

```ruby
  require "right_aws_api"

  ec2 = RightScale::CloudApi::AWS::EC2::Manager.new(key, secret, endpoint)

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

### Options

There is a way to provide extra options when you instantiate a new manager:

```ruby
  options = { :key => value }
  ec2 = RightScale::CloudApi::AWS::EC2::Manager.new(key, secret, endpoint, options)
  sqs = RightScale::CloudApi::AWS::SQS::Manager.new(key, secret, account_number, endpoint, options)
  s3  = RightScale::CloudApi::AWS::S3::Manager::new(key, secret, endpoint, options)
  etc
```

The options allow you to tweak the managers behavoir. Here is a list of the options that make sense for AWS services:

Name                     | Type    | Default                     | Description
-------------------------| --------| ----------------------------|--------------
:abort_on_timeout        | Boolean | false                       | When set to +true+ the gem does not perform a retry call when there is a connection timeout. This may help you to deal with request idempotence issue. Lets say you make a create call and you get back a timeout. It is possible that AWS created a new resource but just failed to report it properly. It is better to stop here rather than keep retrying creating more and more resources.
:api_version             | String  | see service Manager         | The required cloud API version if it is different from the default one.
:cache                   | Boolean | false                       | Cache cloud responses when possible so that we don't parse them again if cloud response does not change (see cloud specific ApiManager definition).
:cloud                   | Hash    | {}                          | A set of cloud or service specific options. There is an only option for AWS S3 so far: :no_dns_buckets => false/true.
:connection_open_timeout | Integer | up to NetHttpPersistent gem | Connection open timeout (in seconds).
:connection_read_timeout | Integer | up to NetHttpPersistent gem | Connection read timeout (in seconds).
:connection_retry_count  | Integer | 3                           | Max number of establish connection retry attempts before it gives up.
:connection_retry_delay  | Float   | 0.5                         | Initial retry backoff delay in seconds. The value is doubled on every retry attempt.
:connection_verify_mode  | Integer | OpenSSL::SSL::VERIFY_PEER   | Try OpenSSL::SSL::VERIFY_NONE is there is an SSL sertificate issue with th eremote end. This may happen when working with DNS-line S3 buckets.
:headers                 | Hash    | {}                          | A set of request headers to be added to every API request.
:logger                  | Logger  | -> STDOUT                   | Current logger. When nil is given it logs to '/dev/nul'.
:log_filter_patterns     | Array   | see DEFAULT_LOG_FILTERS     | A set of log filters that define what to log (see {RightScale::CloudApi::CloudApiLogger}).
:params                  | Hash    | {}                          | A set of URL params to be added to every API request.
:raw_response            | Boolean | false                       | By default the gem parses all XML and JSON responses and returns them as ruby Hashes. Sometimes it is not what one would want (Amazon S3 GetObject for example). Setting this option to +true+ forces the gem to return the body of the response as it is.

For more options see https://github.com/rightscale/right_cloud_api_base/blob/master/lib/base/api_manager.rb

### Response

It is easy to get the last HTTP request and response data:

```ruby
  s3.PutObject('Bucket' => 'a.b.c.d.1.com', 'Object' => '13', :body => 'hahaha') #=> ''

  s3.request.verb    # => 'put'
  s3.request.path    # => '/13'
  s3.request.headers # =>
    {
      "content-type"         => ["binary/octet-stream"],
      "content-length"       => [6],
      "content-md5"          => ["EBpuyfk4iF3wpE8gRY0utA=="],
      "x-amz-content-sha256" => ["23453452345234523452345"],
      "x-amz-date"           => ["20150123T225348Z"],
      "x-amz-expires"        => [3600],
      "host"                 => ["a.b.c.d.1.com.s3.amazonaws.com"],
      "authorization"        => ["AWS4-HMAC-SHA256 Credential=000/20150123/us-east-1/s3/aws4_request, SignedHeaders=content-length;content-md5;content-type;host;x-amz-content-sha256;x-amz-date;x-amz-expires, Signature=111"]}
  s3.request.body    #=> "hahaha"

  s3.response.code    #=> '200'
  s3.response.headers #=>
    {
      "x-amz-id-2"       => ["wB/XOQ+dfgdfgdfgwgfdg"],
      "x-amz-request-id" => ["FEC7DEE7C51ACAB3"],
      "date"             => ["Fri, 23 Jan 2015 22:53:49 GMT"],
      "etag"             => ["\"101a6ec9f938885df0a44f20458d2eb4\""],
      "content-length"   => ["0"],
      "server"           => ["AmazonS3"]}
  s3.response.body    #=> ''

```

Furthermore every response value may return its HTTP response code and HTTP headers through 'metadata' method:

```ruby
response1 = s3.GetObject('Bucket' => 'a.b.c.d.1.com', 'Object' => '13')
response2 = s3.GetObject('Bucket' => 'a.b.c.d.1.com', 'Object' => '14')

response1 #=> "hahaha"
response1.metadata #=>
  { :code    => '200',
    :headers =>
    {"x-amz-id-2"       => ["sdasfdasd="],
     "x-amz-request-id" => ["B2AB70B2D081BF2B"],
     "date"             => ["Fri, 23 Jan 2015 23:02:36 GMT"],
     "last-modified"    => ["Fri, 23 Jan 2015 22:53:49 GMT"],
     "etag"             => ["\"2345435234523452345324\""],
     "accept-ranges"    => ["bytes"],
     "content-type"     => ["binary/octet-stream"],
     "content-length"   => ["6"],
     "server"           => ["AmazonS3"]}}

response2 #=> "hohohohoho"
response2.metadata #=>
{ :code    => '200',
  :headers =>
  {"x-amz-id-2"       => ["asdasdf="],
   "x-amz-request-id" => ["50DBC360C934C548"],
   "date"             => ["Fri, 23 Jan 2015 23:02:36 GMT"],
   "last-modified"    => ["Fri, 23 Jan 2015 23:01:55 GMT"],
   "etag"             => ["\"2345345243523452345234\""],
   "accept-ranges"    => ["bytes"],
   "content-type"     => ["binary/octet-stream"],
   "content-length"   => ["10"],
   "server"           => ["AmazonS3"]}}
```



## Dependencies

This gem depends on a base gem which is shared across all RightScale cloud libraries:
https://github.com/rightscale/right_cloud_api_base

### (c) 2014 by RightScale, Inc., see the LICENSE file for the open-source license.
