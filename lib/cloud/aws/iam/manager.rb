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

      module IAM
        
        # Amazon Identity and Access Management (IAM) compatible manager.
        # 
        # @example
        #  require "right_aws_api"
        #
        #  iam = RightScale::CloudApi::AWS::IAM::Manager::new(key, secret, 'https://iam.amazonaws.com')
        #
        #  # Get information about the Access Key IDs associated with the specified user.
        #  iam.ListAccessKeys #=>
        #    {"ListAccessKeysResponse"=>
        #      {"@xmlns"=>"https://iam.amazonaws.com/doc/2010-05-08/",
        #       "ListAccessKeysResult"=>
        #        {"IsTruncated"=>"false",
        #         "AccessKeyMetadata"=>
        #          {"member"=>
        #            [{"Status"=>"Inactive",
        #              "AccessKeyId"=>"AKIAJ23FVBWT2CPC74RQ",
        #              "CreateDate"=>"2010-11-19T07:40:23Z"},
        #             {"Status"=>"Active",
        #              "AccessKeyId"=>"AKIAJDAKGFLR3C44FUTA",
        #              "CreateDate"=>"2011-10-14T23:32:16Z"}]}},
        #       "ResponseMetadata"=>{"RequestId"=>"68732a2a-4f72-11e2-8c9d-7786bfa02548"}}}
        #
        # @example
        #  # List keys by user
        #  iam.ListAccessKeys('UserName' => 'Bob')
        #
        # @example
        #  # Create a new User
        #  iam.CreateUser('Path' => '/division_abc/subdivision_xyz/bob/',
        #                 'UserName' => 'Bob')
        #
        # @see http://docs.aws.amazon.com/IAM/latest/APIReference/API_Operations.html
        #
        class Manager < AWS::Manager
        end

        class  ApiManager < AWS::ApiManager

          # Default API version for Identity and Access Management service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2010-05-08'

          error_pattern :abort_on_timeout,     :path     => /Action=(Create|Put)/
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