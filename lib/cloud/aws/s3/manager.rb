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
require "cloud/aws/s3/parsers/response_error"
require "cloud/aws/s3/wrappers/default"
require "cloud/aws/s3/routines/request_signer"

module RightScale
  module CloudApi
    module AWS
      module S3

        # Amazon Simple Storage Service (S3) compatible manager.
        #
        # @example
        #  require "right_aws_api"
        #  require "aws/s3"
        #
        #  s3 = RightScale::CloudApi::AWS::S3::new(key, secret, 'https://s3.amazonaws.com')
        #
        #  # -- HTTP verb methods way --
        #  
        #  # List all buckets
        #  s3.get
        #
        #  # List bucket objects
        #  s3.get('devs-us-east')
        #
        #  # Get bucket ACL
        #  s3.get('devs-us-east', :params => {'acl' => nil} )
        #
        #  # Get bucket Version
        #  s3.get('devs-us-east', :params => {'version' => nil} )
        #
        #  # Get object
        #  s3.get('devs-us-east/boot1.jpg')
        #
        #  # Put object
        #  s3.put('devs-us-east/boot1.jpg', :body => 'This is my object DATA. WooHoo!!!')
        #
        # @example
        #  # -- Patterns and Wrappers way (see cloud/aws/s3/wrappers/default.rb)
        #  
        #  s3.ListBuckets #=> 
        #    {"ListAllMyBucketsResult"=>
        #      {"Buckets"=>
        #        {"Bucket"=>
        #          [{"Name"=>"CI_right_test",
        #            "CreationDate"=>"2011-05-25T20:46:28.000Z"},
        #           {"Name"=>"CR_right_test",
        #            "CreationDate"=>"2011-06-08T20:46:32.000Z"},
        #           {"Name"=>"DarrylTest", 
        #            "CreationDate"=>"2011-06-03T03:43:08.000Z"},
        #           {"Name"=>"RightScalePeter", 
        #            "CreationDate"=>"2008-10-28T03:59:20.000Z"}, ...
        #       "Owner"=>
        #        {"DisplayName"=>"fghsfg",
        #         "ID"=>"16144ab2929314cc309ffe736daa2b264357476c7fea6efb2c3347ac3ab2792a"},
        #       "@xmlns"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}
        #
        #  s3.ListObjects('Bucket' => 'devs-us-east', 'max-keys' => 3, 'prefix' => 'kd') #=>
        #    {"ListBucketResult"=>
        #      {"MaxKeys"=>"3",
        #       "IsTruncated"=>"false",
        #       "Name"=>"devs-us-east",
        #       "Marker"=>nil,
        #       "Contents"=>
        #        {"LastModified"=>"2010-08-26T12:23:30.000Z",
        #         "StorageClass"=>"STANDARD",
        #         "ETag"=>"\"3c9a2717e34efedb6d6ac007b2acb8df\"",
        #         "Owner"=>
        #          {"DisplayName"=>"thve",
        #           "ID"=>
        #            "16144ab2929314cc309ffe736daa2b264357476c7fea6efb2c3347ac3ab2792a"},
        #         "Size"=>"3257230",
        #         "Key"=>"kd/boot.jpg"},
        #       "@xmlns"=>"http://s3.amazonaws.com/doc/2006-03-01/",
        #       "Prefix"=>"kd"}}        
        #
        # @example
        #  # Bucket CORS:
        #
        #  # Get
        #  s3.GetBucketCors('Bucket' => 'my-bucket' ) #=>
        #    {"CORSConfiguration"=>
        #        {"@xmlns"=>"http://s3.amazonaws.com/doc/2006-03-01/",
        #        "CORSRule"=>
        #          [{"AllowedOrigin"=>"http://www.example.com",
        #            "AllowedMethod"=>["PUT", "POST"],
        #            "MaxAgeSeconds"=>"2000",
        #            "ExposeHeader"=>"x-amz-server-side-encryption"},
        #          {"AllowedOrigin"=>"*", "AllowedMethod"=>"GET", "MaxAgeSeconds"=>"2001"}]}}
        #
        # @example
        #  # Put
        #  cors_rules = [ { 'AllowedOrigin' => 'http://www.example.com',
        #                   'AllowedMethod' => ['PUT', 'POST'],
        #                   'MaxAgeSeconds' => 3000,
        #                   'ExposeHeader'  => 'x-amz-server-side-encryption' },
        #                 { 'AllowedOrigin' => '*',
        #                   'AllowedMethod' => 'GET',
        #                   'MaxAgeSeconds' => 3000 } ]
        # pp s3.PutBucketCors('Bucket' => 'kd-ver-test', 'CORSRule' => cors_rules ) #=> ''
        #
        #  # .. or
        #  body = "<CORSConfiguration><CORSRule><AllowedOrigin>http://www.example.com</AllowedOrigin>"+
        #         "<AllowedMethod>PUT</AllowedMethod><AllowedMethod>POST</AllowedMethod>"+
        #         "<MaxAgeSeconds>3000</MaxAgeSeconds>..</CORSConfiguration>"
        #  s3.PutBucketCors('Bucket' => 'my-bucket', :body => body ) #=> ''
        #
        # @example
        #  # Delete
        #  s3.DeleteBucketCors('Bucket' => 'my-bucket' ) #=> ''
        #
        # @example
        #  # Bucket Tagging
        #  # Get
        #  s3.GetBucketTagging('Bucket' => 'my-bucket' ) #=>
        #    {"Tagging"=>
        #       "TagSet"=>
        #          "Tag"=>
        #            [{"Key"=>"Project",
        #              "Value"=>"Project One"},
        #             {"Key"=>"User",
        #              "Value"=>"jsmith"} ] }
        #
        # @example
        #  # Delete
        #  s3.DeleteBucketTagging('Bucket' => 'my-bucket' ) #=> ''
        #
        # @example
        #  # Put
        #  tagging_rules = [{"Key"=>"Project",
        #                    "Value"=>"Project One"},
        #                   {"Key"=>"User",
        #                    "Value"=>"jsmith"} ]
        #  s3.PutBucketTagging('Bucket' => 'my-bucket', 'TagSet' => tagging_rules ) #=> ''
        #
        # @example
        #  # Bucket Lifecycle
        #  # Get
        #  s3.GetBucketLifecycle('Bucket' => 'my-bucket' ) #=>
        #    {"LifecycleConfiguration"=>
        #       "Rule"=>[
        #                 {
        #                   "ID" => "30-day-log-deletion-rule",
        #                   "Prefix" => "logs",
        #                   "Status" => "Enabled",
        #                   "Expiration" => {
        #                     "Days" => 30
        #                   }
        #                 }
        #               ] }
        #
        # @example
        #  # Delete
        #  s3.DeleteBucketLifecycle('Bucket' => 'my-bucket' ) #=> ''
        #
        # @example
        #  # Put
        #  lifecycle_rules = [
        #                      {
        #                        "ID" => "30-day-log-deletion-rule",
        #                        "Prefix" => "logs",
        #                        "Status" => "Enabled",
        #                        "Expiration" => {
        #                          "Days" => 30
        #                        }
        #                      },
        #                      {
        #                        "ID" => "delete-documents-rule",
        #                        "Prefix" => "documents",
        #                        "Status" => "Enabled",
        #                        "Expiration" => {
        #                          "Days" => 365
        #                        }
        #                      },
        #                    ] }
        #  s3.PutBucketLifecycle('Bucket' => 'my-bucket', 'Rule' => lifecycle_rules ) #=> ''
        #
        # @see http://docs.aws.amazon.com/AmazonS3/latest/API/APIRest.html
        #
        # @see file:cloud/aws/s3/wrappers/default.rb
        #
        class Manager < CloudApi::Manager
        end

        class  ApiManager < CloudApi::ApiManager
          class Error < CloudApi::Error
          end

          include Mixin::QueryApiPatterns

          set_routine CloudApi::RetryManager
          set_routine CloudApi::RequestInitializer
          set_routine AWS::S3::RequestSigner
          set_routine CloudApi::RequestGenerator
          set_routine CloudApi::ConnectionProxy
          set_routine CloudApi::ResponseAnalyzer
          set_routine CloudApi::ResponseParser
          set_routine CloudApi::ResultWrapper

          set :response_error_parser => Parser::AWS::S3::ResponseError

          def initialize(aws_access_key_id, aws_secret_access_key, endpoint, options={})
            credentials = { :aws_access_key_id     => aws_access_key_id,
                            :aws_secret_access_key => aws_secret_access_key }
            super(credentials, endpoint, options)
          end

          # Make an API call to AWS::S3 compatible cloud.
          # 
          # opts: [:options, :headers, :params, :body]
          # body: String, IO, Nil.
          #
          # Usage: api(verb,                  opts={})
          #        api(verb, 'bucket',        opts={})
          #        api(verb, 'bucket/object', opts={})
          #
          def api(verb, *args, &block)
            relative_path = args.first.is_a?(String) ? args.shift : ''
            opts          = args.shift || {}
            raise Error::new("Opts must be Hash not #{opts.class.name}") unless opts.is_a?(Hash)
            process_api_request(verb, relative_path, opts, &block)
          end
          
        end

      end
    end
  end
end