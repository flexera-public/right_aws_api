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

      # Simple Notification Service namespace
      #
      # @api public
      #
      module SNS
        
        # Amazon Simple Notification Service (SNS) compatible clouds manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  sns = RightScale::CloudApi::AWS::SNS::Manager.new(
        #    ENV['AWS_ACCESS_KEY_ID'],
        #    ENV['AWS_SECRET_ACCESS_KEY'],
        #    'https://sns.us-east-1.amazonaws.com')
        #
        # @example
        #  sns.CreateTopic('Name' => 'myNewTopic') #=>
        #    {"CreateTopicResponse"=>
        #      {"@xmlns"=>"http://sns.amazonaws.com/doc/2010-03-31/",
        #       "CreateTopicResult"=>
        #        {"TopicArn"=>"arn:aws:sns:us-east-1:826693181925:myNewTopic"},
        #       "ResponseMetadata"=>{"RequestId"=>"ba2c7170-8d8f-11e1-99c8-cd4871234eac"}}}
        #
        # @example
        #  sns.ListSubscriptions #=>
        #    {"ListSubscriptionsResponse"=>
        #      {"@xmlns"=>"http://sns.amazonaws.com/doc/2010-03-31/",
        #       "ListSubscriptionsResult"=>{"Subscriptions"=>nil},
        #       "ResponseMetadata"=>{"RequestId"=>"8d53941d-8d8f-11e1-a165-a1021f73c0e5"}}}
        #
        # @see ApiManager
        # @see http://docs.amazonwebservices.com/sns/latest/api/API_Operations.html
        #
        class Manager < AWS::Manager
        end


        # Amazon Simple Notification Service (SNS) compatible clouds manager (thread unsafe).
        #
        # @see Manager
        #
        class  ApiManager < AWS::ApiManager

          # Default API version for SNS service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2010-03-31'

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