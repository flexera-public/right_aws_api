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

      module RDS
        
        # Amazon Relational Database Service (RDS) compatible manager.
        #
        # @example
        #  require "right_aws_api"
        #  require "aws/rds"
        #
        #  rds = RightScale::CloudApi::AWS::RDS::Manager::new(key, secret, 'https://rds.amazonaws.com')
        #
        #  # Describe DB Engine Versions
        #  rds.DescribeDBEngineVersions #=>
        #    {"DescribeDBEngineVersionsResponse"=>
        #      {"@xmlns"=>"http://rds.amazonaws.com/doc/2011-04-01/",
        #       "DescribeDBEngineVersionsResult"=>
        #        {"DBEngineVersions"=>
        #          {"DBEngineVersion"=>
        #            [{"DBParameterGroupFamily"=>"mysql5.1",
        #              "Engine"=>"mysql",
        #              "DBEngineDescription"=>"MySQL Community Edition",
        #              "EngineVersion"=>"5.1.45",
        #              "DBEngineVersionDescription"=>"MySQL 5.1.45"},
        #              ...
        #             {"DBParameterGroupFamily"=>"sqlserver-web-11.0",
        #              "Engine"=>"sqlserver-web",
        #              "DBEngineDescription"=>"Microsoft SQL Server Web Edition",
        #              "EngineVersion"=>"11.00.2100.60.v1",
        #              "DBEngineVersionDescription"=>"SQL Server 2012 11.00.2100.60.v1"}]}},
        #       "ResponseMetadata"=>{"RequestId"=>"2cea9327-4f73-11e2-b200-6b97351ff318"}}}
        #
        # @example
        #  # Create a new RDS instance
        #  rds.CreateDBInstance( 'DBInstanceIdentifier' => 'SimCoProd01',
        #                        'Engine'               => 'mysql',
        #                        'MasterUserPassword'   => 'Password01',
        #                        'AllocatedStorage'     => 10,
        #                        'MasterUsername'       => 'master',
        #                        'DBInstanceClass'      => 'db.m1.large',
        #                        'DBSubnetGroupName'    => 'dbSubnetgroup01')
        #
        # @example
        #  # Delete an instance
        #  rds.DeleteDBInstance('DBInstanceIdentifier' => 'SimCoProd01')
        #
        # @see http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_Operations.html
        #
        class Manager < AWS::Manager
        end

        class  ApiManager < AWS::ApiManager

          # Default API version for RDS service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2013-02-12'
          
          error_pattern :abort_on_timeout,     :path     => /Action=(Create|Purchase)/
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