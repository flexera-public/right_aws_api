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

      # Simple Storage Service namespace
      #
      # @api public
      #
      module S3

        # Amazon Simple Storage Service (S3) compatible manager (thread safe).
        #
        # @example
        #  require "right_aws_api"
        #
        #  s3 = RightScale::CloudApi::AWS::S3::new(key, secret, 'https://s3.amazonaws.com')
        #
        # @example
        #  # -- Through HTTP verb methods --
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
        #   # A simple example of a multi-thread file download:
        #   threads    = []
        #   file_size  = 3257230
        #   chunks     = 3
        #   chunk_size = file_size / chunks
        #   chunks.times do |i|
        #     from_byte = i * chunk_size
        #     to_byte   = from_byte + chunk_size - 1
        #     to_byte  += file_size % chunks if i + 1 == chunks
        #     threads << Thread::new {
        #       Thread.current[:my_file] = s3.get('devs-us-east/xxx/boot.jpg', {:headers => {'Range' => "bytes=#{from_byte}-#{to_byte}"}})
        #     }
        #   end
        #   file_body = ''
        #   threads.each do |thread|
        #     thread.join
        #     file_body << thread[:my_file]
        #   end
        #   file_body.size #=> 3257230
        #
        # @example
        #   # Download into IO object
        #   File.open('/tmp/boot.jpg','w') do |file|
        #     s3.get('devs-us-east/kd/boot.jpg') do |chunk|
        #       file.write(chunk)
        #     end
        #   end
        #
        # @example
        #  # -- Through Query API Patterns/Wrappers (see {Wrapper::DEFAULT.extended})
        #  
        #  # List all buckets
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
        #            "CreationDate"=>"2008-10-28T03:59:20.000Z"}]},
        #       "Owner"=>
        #        {"DisplayName"=>"fghsfg",
        #         "ID"=>"16144ab2929314cc309ffe736daa2b264357476c7fea6efb2c3347ac3ab2792a"},
        #       "@xmlns"=>"http://s3.amazonaws.com/doc/2006-03-01/"}}
        #
        #  # List bucket objects
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
        #  cors_rules = [
        #    {'AllowedOrigin' => 'http://www.example.com',
        #     'AllowedMethod' => ['PUT', 'POST'],
        #     'MaxAgeSeconds' => 3000,
        #     'ExposeHeader'  => 'x-amz-server-side-encryption' },
        #    {'AllowedOrigin' => '*',
        #     'AllowedMethod' => 'GET',
        #     'MaxAgeSeconds' => 3000 } ]
        #  s3.PutBucketCors('Bucket' => 'kd-ver-test', 'CORSRule' => cors_rules ) #=> ''
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
        #    {"Tagging"=> {
        #       "TagSet"=> {
        #          "Tag"=>[
        #            {"Key"=>"Project",
        #              "Value"=>"Project One"},
        #             {"Key"=>"User",
        #              "Value"=>"jsmith"}]}}}
        #
        # @example
        #  # Delete
        #  s3.DeleteBucketTagging('Bucket' => 'my-bucket' ) #=> ''
        #
        # @example
        #  # Put
        #  tagging_rules = [
        #    {"Key"=>"Project",
        #     "Value"=>"Project One"},
        #    {"Key"=>"User",
        #     "Value"=>"jsmith"} ]
        #  s3.PutBucketTagging('Bucket' => 'my-bucket', 'TagSet' => tagging_rules ) #=> ''
        #
        # @example
        #  # Bucket Lifecycle
        #  # Get
        #  s3.GetBucketLifecycle('Bucket' => 'my-bucket' ) #=>
        #    {"LifecycleConfiguration"=> {
        #       "Rule"=>[{
        #         "ID" => "30-day-log-deletion-rule",
        #         "Prefix" => "logs",
        #         "Status" => "Enabled",
        #         "Expiration" => { "Days" => 30 }}]}}
        #
        # @example
        #  # Delete
        #  s3.DeleteBucketLifecycle('Bucket' => 'my-bucket' ) #=> ''
        #
        # @example
        #  # Put
        #  lifecycle_rules = [
        #    { "ID"         => "30-day-log-deletion-rule",
        #      "Prefix"     => "logs",
        #      "Status"     => "Enabled",
        #      "Expiration" => {"Days" => 30}},
        #    {"ID"          => "delete-documents-rule",
        #      "Prefix"     => "documents",
        #      "Status"     => "Enabled",
        #      "Expiration" => { "Days" => 365 }}]
        #  s3.PutBucketLifecycle('Bucket' => 'my-bucket', 'Rule' => lifecycle_rules ) #=> ''
        #
        # @example
        #  # Get a link to ListAllMyBuckets action
        #  s3.ListAllMyBuckets(:options=>{:cloud=>{:link=>true}}) #=> 
        #    {"verb"   => "get",
        #     "link"   => "https://s3.amazonaws.com/?AWSAccessKeyId=0K4QH...G2&Expires=1426111071&Signature=vLMH...3D",
        #     "headers"=> {"host"=>["s3.amazonaws.com"]}}
        #
        #  # If you need to get a bunch of links you can use with_options helper method:
        #  opts = {:headers => {'expires' => Time.now + 3600}}
        #  s3.with_options(:cloud=>{:link => true}) do
        #    pp s3.GetObject({'Bucket'=>'my-bucket', 'Object'=>'kd/kd0.test', 'versionId'=>"00eYZeb291o4"}, opts)
        #    pp s3.GetObject({'Bucket'=>'my-bucket', 'Object'=>'kd/kd1.test', 'versionId'=>"fafaf1obp1W4"}, opts)
        #    pp s3.GetObject({'Bucket'=>'my-bucket', 'Object'=>'kd/kd2.test', 'versionId'=>"00asdTebp1W4"}, opts)
        #    pp s3.GetObject({'Bucket'=>'my-bucket', 'Object'=>'kd/kd3.test', 'versionId'=>"0lkjreobp1W4"}, opts)
        #  end
        #
        # @see ApiManager
        # @see Wrapper::DEFAULT.extended Wrapper::DEFAULT.extended (click [View source])
        # @see http://docs.aws.amazon.com/AmazonS3/latest/API/APIRest.html
        #
        class Manager < CloudApi::Manager
        end


        # Amazon Simple Storage Service (S3) compatible manager (thread unsafe).
        #
        # @see Manager
        #
        class  ApiManager < CloudApi::ApiManager

          # S3 Error
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


          # Constructor
          #
          # @param [String] aws_access_key_id
          # @param [String] aws_secret_access_key
          # @param [String] endpoint
          # @param [Hash]   options
          #
          # @example
          #   # see Manager class
          #
          # @see Manager
          #
          def initialize(aws_access_key_id, aws_secret_access_key, endpoint, options={})
            credentials = { :aws_access_key_id     => aws_access_key_id,
                            :aws_secret_access_key => aws_secret_access_key }
            super(credentials, endpoint, options)
          end


          # Makes an API call to AWS::S3 compatible cloud
          #
          # @param [String,Symbol] verb  'get' | 'put' | etc
          # @param [Objects] args
          #
          # @return [Object]
          #
          # @example
          #   api(verb,                  opts={})
          #   api(verb, 'bucket',        opts={})
          #   # Where opts may have next keys: :options, :headers, :params, :body
          #   api(verb, 'bucket/object', opts={})
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