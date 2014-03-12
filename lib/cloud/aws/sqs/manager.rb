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
require "cloud/aws/base/routines/request_signer"
require "cloud/aws/base/parsers/response_error"

module RightScale
  module CloudApi
    module AWS
      
      # Simple Queue Service namespace
      #
      # @api public
      #
      module SQS

        # Amazon Simple Queue Service (SQS) compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  # Create a manager
        #  sqs = RightScale::CloudApi::AWS::SQS::Manager.new(
        #          ENV['AWS_ACCESS_KEY_ID'],
        #          ENV['AWS_SECRET_ACCESS_KEY'],
        #          ENV['AWS_ACCOUNT_NUMBER'],
        #          'https://sqs.us-east-1.amazonaws.com')
        #
        #  # List all queues
        #  sqs.ListQueues #=>
        #    {"ListQueuesResponse"=>
        #      {"ResponseMetadata"=>{"RequestId"=>"9db0c9d7-35cf-4477-bc13-bbeacaf16d9b"},
        #       "@xmlns"=>"http://queue.amazonaws.com/doc/2011-10-01/",
        #       "ListQueuesResult"=>
        #        {"QueueUrl"=>
        #           ["https://sqs.us-east-1.amazonaws.com/826693181925/Abracadabra",
        #            "https://sqs.us-east-1.amazonaws.com/826693181925/JM-Output"] }}}
        #
        # @example
        #  # Create new queue (Amazon way)...
        #  sqs.CreateQueue( 'QueueName'         => 'myCoolQueue',
        #                   'Attribute.1.Name'  => 'VisibilityTimeout',
        #                   'Attribute.1.Value' => '40',
        #                   'Attribute.2.Name'  => 'MaximumMessageSize',
        #                   'Attribute.2.Value' => '2048' )
        #                   
        #  # ... or using CloudApi way:
        #  sqs.CreateQueue( 'QueueName' => 'myCoolQueue',
        #                   'Attribute' => [
        #                     { 'Name'  => 'VisibilityTimeout',  'Value' => 40 },
        #                     { 'Name'  => 'MaximumMessageSize', 'Value' => 2048 } ])
        #    {"CreateQueueResponse"=>
        #      {"CreateQueueResult"=>
        #        {"QueueUrl"=>
        #          "https://sqs.us-east-1.amazonaws.com/826693181925/myCoolQueue1"},
        #       "ResponseMetadata"=>{"RequestId"=>"bf32f187-00e2-4327-8207-9aa6f786c654"},
        #       "@xmlns"=>"http://queue.amazonaws.com/doc/2011-10-01/"}}
        #
        # When Amazon API expects Queue to be a part of a path then put the name as first parameter:
        #
        # @example
        #  # sqs.GetQueueAttributes('myCoolQueue', 'AttributeName' => ['VisibilityTimeout', 'MaximumMessageSize', 'ApproximateNumberOfMessages']) #=>
        #    {"GetQueueAttributesResponse"=>
        #      {"@xmlns"=>"http://queue.amazonaws.com/doc/2011-10-01/",
        #       "GetQueueAttributesResult"=>
        #        {"Attribute"=>
        #          [{"Name"=>"VisibilityTimeout", "Value"=>"40"},
        #           {"Name"=>"MaximumMessageSize", "Value"=>"2048"},
        #           {"Name"=>"ApproximateNumberOfMessages", "Value"=>"0"}]},
        #       "ResponseMetadata"=>{"RequestId"=>"f70ca08f-97d6-4787-856d-e447529c6a26"}}}
        #
        # @example
        #  # Send message (do not forget to escape it)
        #  message = 'A big brown dog jumped over the fox'
        #  sqs.SendMessage('myCoolQueue1', 'MessageBody' => URI::escape(message)) #=>
        #    {"SendMessageResponse"=>
        #      {"ResponseMetadata"=>{"RequestId"=>"df903a9d-8409-421d-9ca4-2ccdaf3a38b3"},
        #       "SendMessageResult"=>
        #        {"MessageId"=>"462df5b0-a7f9-40af-8951-b47ec664cfd9",
        #         "MD5OfMessageBody"=>"cf16267845abfaaa6297db494b2c90e8"},
        #       "@xmlns"=>"http://queue.amazonaws.com/doc/2011-10-01/"}}
        #
        # @example
        #   # Receive message (then unescape it when needed)
        #   sqs.ReceiveMessage('myCoolQueue') #=> 
        #      {"ReceiveMessageResponse"=>
        #        {"ReceiveMessageResult"=>
        #          {"Message"=>
        #            {"ReceiptHandle"=>
        #              "Prl0vft3nRgHmktg983Id8/3NhzTWnxZAtOv0Jr3qdfKsqBR68Pl4basOMqgGO3jF2yeAcI4nKhmtDuS7jqOpBE7mbdwfiUFDn55yssPQWcaxxjGVWeu+p45YGxn2aqU6fh4OnTDebUWsBLCPSc9uf+cRuJOwodzeVVT1XUKYxlnwvZJa2qD17wfitoJp5F/lFy4yU0GaDP4VF5icb/AfzxYuO7kg0p9Cswf0pPkWYgV+BOe9Ri0GELw4YkTLMInHk93NtdcWtgM51zbmwDDhOQDIQdfkcKw1z9OdHsr1+4=",
        #             "Body"=>"A%20big%20brown%20dog%20jumped%20over%20the%20fox",
        #             "MD5OfBody"=>"a1bb5681fa24d4f437eeba5a1dd305c1",
        #             "MessageId"=>"71ba4c68-54c9-4ae2-a272-626a6905593b"}},
        #         "ResponseMetadata"=>{"RequestId"=>"c77ab769-ff74-4fdb-ab86-fb9219ab3e0c"},
        #         "@xmlns"=>"http://queue.amazonaws.com/doc/2011-10-01/"}}
        #
        # @example
        #  # Send message batch (Amazon way) ...
        #  sqs.SendMessageBatch('myCoolQueue',
        #    'SendMessageBatchRequestEntry.1.Id'           => 1,
        #    'SendMessageBatchRequestEntry.1.DelaySeconds' => 300,
        #    'SendMessageBatchRequestEntry.1.MessageBody'  => CGI::escape('Hahaha!'),
        #    'SendMessageBatchRequestEntry.2.Id'           => 2,
        #    'SendMessageBatchRequestEntry.2.DelaySeconds' => 310,
        #    'SendMessageBatchRequestEntry.2.MessageBody'  => CGI::escape('Hahaha!!'),
        #    'SendMessageBatchRequestEntry.3.Id'           => 3,
        #    'SendMessageBatchRequestEntry.3.DelaySeconds' => 320,
        #    'SendMessageBatchRequestEntry.3.MessageBody'  => CGI::escape('Hahaha!!!'),
        #    'SendMessageBatchRequestEntry.4.Id'           => 4,
        #    'SendMessageBatchRequestEntry.4.DelaySeconds' => 330,
        #    'SendMessageBatchRequestEntry.4.MessageBody'  => CGI::escape('Hahaha!!!!') )
        #
        #  # ... or using CloudApi way:
        #  sqs.SendMessageBatch('myCoolQueue',
        #    'SendMessageBatchRequestEntry' => [
        #      { 'Id' => 1, 'DelaySeconds' => 300, 'MessageBody' => CGI::escape('Hahaha!') },
        #      { 'Id' => 2, 'DelaySeconds' => 310, 'MessageBody' => CGI::escape('Hahaha!!') },
        #      { 'Id' => 3, 'DelaySeconds' => 320, 'MessageBody' => CGI::escape('Hahaha!!!') },
        #      { 'Id' => 4, 'DelaySeconds' => 330, 'MessageBody' => CGI::escape('Hahaha!!!!') } ] ) #=>
        #    {"SendMessageBatchResponse"=>
        #      {"SendMessageBatchResult"=>
        #        {"SendMessageBatchResultEntry"=>
        #          [{"MessageId"=>"8bc2891f-e2d6-4b92-9138-6fa7d2552e2d",
        #            "Id"=>"1",
        #            "MD5OfMessageBody"=>"c5bfc3f4240d74756238a1e390cc1391"},
        #           {"MessageId"=>"bc52eaf2-9f57-48c2-aa2d-7c3507bc306e",
        #            "Id"=>"2",
        #            "MD5OfMessageBody"=>"659355aa82149d1334942b5879da028e"},
        #           {"MessageId"=>"a7a14acd-b722-4146-be55-34167bb9dac8",
        #            "Id"=>"3",
        #            "MD5OfMessageBody"=>"faf2f2992906f2daf49f35c302dc3454"},
        #           {"MessageId"=>"cd443cd2-68a1-4456-b593-a964f336f12e",
        #            "Id"=>"4",
        #            "MD5OfMessageBody"=>"4033563a06b308f7366ca3d6bc7e3151"}]},
        #       "ResponseMetadata"=>{"RequestId"=>"7237d096-677d-4bc6-be44-7a1a313d18d6"},
        #       "@xmlns"=>"http://queue.amazonaws.com/doc/2011-10-01/"}}
        #
        # @example
        #  # Get queue attributes:
        #  sqs.GetQueueAttributes('myCoolQueue', 'AttributeName' => 'All') #=>
        #    {"GetQueueAttributesResponse"=>
        #      {"GetQueueAttributesResult"=>
        #        {"Attribute"=>
        #          [{"Name"=>"VisibilityTimeout", "Value"=>"40"},
        #           {"Name"=>"ApproximateNumberOfMessages", "Value"=>"7"},
        #           {"Name"=>"ApproximateNumberOfMessagesNotVisible", "Value"=>"0"},
        #           {"Name"=>"ApproximateNumberOfMessagesDelayed", "Value"=>"0"},
        #           {"Name"=>"CreatedTimestamp", "Value"=>"1322001625"},
        #           {"Name"=>"LastModifiedTimestamp", "Value"=>"1322001625"},
        #           {"Name"=>"QueueArn", "Value"=>"arn:aws:sqs:us-east-1:826693181925:myCoolQueue"},
        #           {"Name"=>"MaximumMessageSize", "Value"=>"2048"},
        #           {"Name"=>"MessageRetentionPeriod", "Value"=>"345600"},
        #           {"Name"=>"DelaySeconds", "Value"=>"0"}]},
        #       "ResponseMetadata"=>{"RequestId"=>"85b2d5f4-b63e-44bc-845c-14e4ae16cb9e"},
        #       "@xmlns"=>"http://queue.amazonaws.com/doc/2011-10-01/"}}
        #
        # @example
        #  # Delete queue:
        #  sqs.DeleteQueue('myCoolQueue1') #=>
        #    {"DeleteQueueResponse"=>
        #      {"ResponseMetadata"=>{"RequestId"=>"01de6439-6817-4308-8645-2a9430316e8a"},
        #       "@xmlns"=>"http://queue.amazonaws.com/doc/2011-10-01/"}}
        #
        # @see ApiManager
        # @see http://docs.amazonwebservices.com/AWSSimpleQueueService/latest/APIReference
        #
        class Manager < CloudApi::Manager
        end


        # Amazon Simple Queue Service (SQS) compatible manager (thread unsafe).
        #
        # @see Manager
        #
        class ApiManager < CloudApi::ApiManager

          # SQS Error
          class Error < CloudApi::Error
          end

          # Default API version for SQS service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2011-10-01'

          set_routine CloudApi::RetryManager
          set_routine CloudApi::RequestInitializer
          set_routine AWS::RequestSigner
          set_routine CloudApi::RequestGenerator
          set_routine CloudApi::RequestAnalyzer
          set_routine CloudApi::ConnectionProxy
          set_routine CloudApi::ResponseAnalyzer
          set_routine CloudApi::ResponseParser
          set_routine CloudApi::ResultWrapper

          error_pattern :abort_on_timeout,     :path     => /Action=Create/
          error_pattern :retry,                :response => /InternalError|Unavailable|ServiceUnavailable/i
          error_pattern :disconnect_and_abort, :code     => /5..|403|408/
          error_pattern :disconnect_and_abort, :code     => /4../, :if => Proc.new{ |opts| rand(100) < 10 }

          set :response_error_parser => Parser::AWS::ResponseErrorV2


          # Constructor
          #
          # @param [String] aws_access_key_id
          # @param [String] aws_secret_access_key
          # @param [String] aws_account_number
          # @param [String] endpoint
          # @param [Hash]   options
          #
          # @see Manager
          #
          # @example
          #  # see Manager class
          #
          def initialize(aws_access_key_id, aws_secret_access_key, aws_account_number, endpoint, options={})
            credentials = { :aws_account_number    => aws_account_number,
                            :aws_access_key_id     => aws_access_key_id,
                            :aws_secret_access_key => aws_secret_access_key }
            super(credentials, endpoint, options)
          end

          # Make an API call to AWS::Ec2 compatible cloud
          #
          # @param [String] action The action as Amazon names it in its docs.
          #
          # @return [Object]
          #
          # @example
          #   # Where opts may have next keys: :options, :headers, :body
          #   api(action, queue_name, opts={})
          #   api(action, opts={})
          #
          # @example
          #  sqs.api('ListQueues')
          #
          # @example
          #   sqs.api('SetQueueAttributes', 'myCoolQueue1', {'Attribute.?.Name' => 'Attribute.?.Value'}#
          #
          def api(action, *args)
            queue_name = args.shift if args.first.is_a?(String)
            opts     = args.shift || {}
            # Uri Parameters
            opts['Action'] ||= action.to_s._snake_case._camelize
            options           = {}
            options[:body]    = opts.delete(:body)
            options[:headers] = opts.delete(:headers) || {}
            options[:options] = opts.delete(:options) || {}
            options[:params]  = parametrize(opts)
            # Options and Per Queue URI
            path = queue_name._blank? ? '' : "#{@credentials[:aws_account_number]}/#{queue_name}"
            process_api_request(:get, path, options)
          end


          # Parametrize data to the format that Amazon EC2 and compatible services accept
          #
          # See {RightScale::CloudApi::Utils::AWS.parametrize} for more examples.
          #
          # @return [Hash] A hash of data in the format Amazon want to get.
          #
          # @example
          #  parametrize( 'ParamA'             => 'a',
          #               'ParamB'             => ['b', 'c'],
          #               'ParamC.?.Something' => ['d', 'e'],
          #               'Filter'             => [ { 'Key' => 'A', 'Value' => ['aa','ab']},
          #                                         { 'Key' => 'B', 'Value' => ['ba','bb']}] ) #=>
          #    {
          #      "Filter.1.Key"       => "A",
          #      "Filter.1.Value.1"   => "aa",
          #      "Filter.1.Value.2"   => "ab",
          #      "Filter.2.Key"       => "B",
          #      "Filter.2.Value.1"   => "ba",
          #      "Filter.2.Value.2"   => "bb",
          #      "ParamA"             => "a",
          #      "ParamB.1"           => "b",
          #      "ParamB.2"           => "c",
          #      "ParamC.1.Something" => "d",
          #      "ParamC.2.Something" => "e"
          #    }
          #
          def parametrize(*args) # :nodoc:
            Utils::AWS.parametrize(*args)
          end


          # @api public
          alias_method :p9e, :parametrize


          # Adds an ability to call SQS API methods by their names
          #
          # @return [Object]
          #
          # @example
          #  sqs.ListQueues
          #
          # @example
          #   sqs.SetQueueAttributes('myCoolQueue1', {'Attribute.?.Name' => 'Attribute.?.Value'})
          #
          def method_missing(method_name, *args, &block)
            if method_name.to_s[/\A[A-Z]/]
              api(method_name, *args, &block)
            else
              super
            end
          end

        end
      end
    end
  end
end