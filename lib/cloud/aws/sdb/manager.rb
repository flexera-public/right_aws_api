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

      module SDB
        
        # Amazon SimpleDB (SDB) compatible manager.
        #
        # @example
        #  require "right_aws_api"
        #
        #  # Create a manager to access SDB.
        #  sdb = RightScale::CloudApi::AWS::SDB::Manager::new(key, secret, 'https://sdb.amazonaws.com' )
        #  
        #  sdb.ListDomains #=> 
        #    {"ListDomainsResponse"=>
        #      {"ListDomainsResult"=>
        #        {"DomainName"=>
        #          ["kd_tests",
        #           "kdclient"]},
        #       "ResponseMetadata"=>
        #        {"RequestId"=>"d430ab64-18ff-b529-fc0c-0cae65d68203",
        #         "BoxUsage"=>"0.0000071759"},
        #       "@xmlns"=>"http://sdb.amazonaws.com/doc/2009-04-15/"}}
        #       
        # @example
        #  sdb.PutAttributes('DomainName'   => 'kdclient',
        #                    'ItemName'     => 'Employee',
        #                    'Attribute' => [ { 'Name' => 'name', 'Value' => 'John' },
        #                                      { 'Name' => 'age',  'Value' => '33' },
        #                                      { 'Name' => 'sex',  'Value' => 'male } ]) #=>
        #    {"PutAttributesResponse"=>
        #      {"ResponseMetadata"=>
        #        {"RequestId"=>"210d06ce-8b15-0035-1084-baec98874f75",
        #         "BoxUsage"=>"0.0000219961"},
        #       "@xmlns"=>"http://sdb.amazonaws.com/doc/2009-04-15/"}}
        #
        #
        # @example
        #  # BatchPutAttributes
        #  sdb.BatchPutAttributes( "DomainName"               => "kdclient",
        #                          "Item.1.ItemName"          => "konstantin",
        #                          "Item.1.Attribute.1.Name"  => "sex",
        #                          "Item.1.Attribute.1.Value" => "male",
        #                          "Item.1.Attribute.2.Name"  => "weight",
        #                          "Item.1.Attribute.2.Value" => "170",
        #                          "Item.1.Attribute.3.Name"  => "age",
        #                          "Item.1.Attribute.3.Value" => "38",
        #                          "Item.2.ItemName"          => "alex",
        #                          "Item.2.Attribute.1.Name"  => "sex",
        #                          "Item.2.Attribute.1.Value" => "male",
        #                          "Item.2.Attribute.2.Name"  => "weight",
        #                          "Item.2.Attribute.2.Value" => "188",
        #                          "Item.2.Attribute.3.Name"  => "age",
        #                          "Item.2.Attribute.3.Value" => "42",
        #                          "Item.3.ItemName"          => "diana",
        #                          "Item.3.Attribute.1.Name"  => "sex",
        #                          "Item.3.Attribute.1.Value" => "female",
        #                          "Item.3.Attribute.2.Name"  => "weight",
        #                          "Item.3.Attribute.2.Value" => "120",
        #                          "Item.3.Attribute.3.Name"  => "age",
        #                          "Item.3.Attribute.3.Value" => "25" ) 
        #                            
        #  # ... the same as the call above (see {RightScale::CloudApi::Utils::AWS::parametrize} method usage)
        #  sdb.BatchPutAttributes( 'DomainName' => 'kdclient',
        #                          'Item' => [ { 'ItemName'   => 'konstantin',
        #                                         'Attribute' => [ { 'Name' => 'sex',    'Value' => 'male' },
        #                                                          { 'Name' => 'weight', 'Value' => '170'},
        #                                                          { 'Name' => 'age',    'Value' => '38'} ] },
        #                                      { 'ItemName'   => 'alex',
        #                                        'Attribute'  => [ { 'Name' => 'sex',    'Value' => 'male' },
        #                                                          { 'Name' => 'weight', 'Value' => '188'},
        #                                                          { 'Name' => 'age',    'Value' => '42'} ] },
        #                                      { 'ItemName'   => 'diana',
        #                                        'Attribute'  => [ { 'Name' => 'sex',    'Value' => 'female' },
        #                                                          { 'Name' => 'weight', 'Value' => '120'},
        #                                                          { 'Name' => 'age',    'Value' => '25'} ] } ] ) #=>
        #    {"BatchPutAttributesResponse"=>
        #      {"ResponseMetadata"=>
        #        {"RequestId"=>"4b0d9997-0a51-2c4f-3424-da04225d6ef9",
        #         "BoxUsage"=>"0.0000461918"},
        #       "@xmlns"=>"http://sdb.amazonaws.com/doc/2009-04-15/"}}
        #                                                               
        #  sdb.Select('SelectExpression' => "select name from kdclient where sex = 'female'")
        #
        # @see http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_Operations.html
        #
        class Manager < AWS::Manager
        end

        class  ApiManager < AWS::ApiManager

          # Default API version for SimpleDB service.
          # To override the API version use :api_version key when instantiating a manager.
          #
          DEFAULT_API_VERSION = '2009-04-15'

          error_pattern :abort_on_timeout,     :path     => /Action=(Create|Put|BatchPut)/
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