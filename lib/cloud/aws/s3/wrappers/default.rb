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

module RightScale
  module CloudApi
    module AWS
      module S3

        # S3 Wrapper namespace
        module Wrapper

          # Default wrapper
          module DEFAULT


            # Defines QUERY API like methods for the service.
            def self.extended(base)

              #-----------------
              # Service
              #-----------------

              base.query_api_pattern 'ListAllMyBuckets', :get


              base.query_api_pattern 'ListBuckets', :get  # alias for ListAllMyBuckets


              #-----------------
              # Bucket
              #-----------------


              base.query_api_pattern 'DeleteBucket', :delete, '{:Bucket}'


              base.query_api_pattern 'DeleteBucketPolicy', :delete, '{:Bucket}',
                :params => { 'policy' => nil }


              base.query_api_pattern 'DeleteBucketWebsite', :delete, '{:Bucket}',
                :params => { 'website' => nil }


              base.query_api_pattern 'ListObjects', :get, '{:Bucket}'
              base.query_api_pattern 'GetBucket', :get, '{:Bucket}' # alias for ListObjects


              base.query_api_pattern 'GetBucketAcl', :get, '{:Bucket}',
                :params => { 'acl'=> nil }


              base.query_api_pattern 'GetBucketPolicy',  :get, '{:Bucket}',
                :params => { 'policy'=> nil }


              base.query_api_pattern 'GetBucketLocation',  :get, '{:Bucket}',
                :params => { 'location'=> nil }


              base.query_api_pattern 'GetBucketLogging',  :get, '{:Bucket}',
                :params => { 'logging'=> nil }


              base.query_api_pattern 'GetBucketNotification', :get, '{:Bucket}',
                :params => { 'notification'=> nil }


              base.query_api_pattern 'GetBucketVersions',  :get, '{:Bucket}',
                :params => { 'versions'=> nil }


              base.query_api_pattern 'GetBucketRequestPayment', :get, '{:Bucket}',
                :params => { 'requestPayment'=> nil }


              base.query_api_pattern 'GetBucketVersioning', :get, '{:Bucket}',
                :params => { 'versioning'=> nil }


              base.query_api_pattern 'GetBucketWebsite', :get, '{:Bucket}',
                :params => { 'website'=> nil }


              base.query_api_pattern 'ListMultipartUploads',  :get, '{:Bucket}',
                :params => { 'uploads'=> nil }


              base.query_api_pattern 'PutBucket', :put, '{:Bucket}'


              base.query_api_pattern 'PutBucketAcl', :put, '{:Bucket}',
                :params => { 'acl' => nil },
                :body   => { 'AccessControlPolicy' => :AccessControlPolicy }


              base.query_api_pattern 'PutBucketPolicy', :put, '{:Bucket}',
                :params  => { 'policy' => nil },
                :body    => Utils::MUST_BE_SET,
                :headers => { 'content-type' => 'application/json' }


              base.query_api_pattern 'PutBucketLogging', :put, '{:Bucket}',
                :params => { 'logging' => nil },
                :body   => { 'BucketLoggingStatus' => :BucketLoggingStatus }


              base.query_api_pattern 'PutBucketNotification', :put, '{:Bucket}',
                :params => { 'notification' => nil },
                :body   => { 'NotificationConfiguration' => :NotificationConfiguration }


              base.query_api_pattern 'PutBucketRequestPayment', :put, '{:Bucket}',
                :params => { 'requestPayment' => nil },
                :body   => { 'RequestPaymentConfiguration' => :RequestPaymentConfiguration }


              base.query_api_pattern 'PutBucketVersioning', :put, '{:Bucket}',
                :params => { 'versioning' => nil },
                :body   => { 'VersioningConfiguration' => :VersioningConfiguration }


              base.query_api_pattern 'PutBucketWebsite', :put, '{:Bucket}',
                :params => { 'website' => nil },
                :body   => { 'WebsiteConfiguration' => :WebsiteConfiguration }

              base.query_api_pattern 'GetBucketCors', :get, '{:Bucket}',
                :params => { 'cors'=> nil }

              base.query_api_pattern 'DeleteBucketCors',  :delete, '{:Bucket}',
                :params => { 'cors'=> nil }

              base.query_api_pattern 'PutBucketCors',  :put, '{:Bucket}',
                :params => { 'cors'=> nil },
              :body   => { 'CORSConfiguration' => {
              'CORSRule' => :CORSRule } }

              base.query_api_pattern 'GetBucketTagging', :get, '{:Bucket}',
                :params => { 'tagging' => nil }

              base.query_api_pattern 'PutBucketTagging', :put, '{:Bucket}',
                :params => { 'tagging' => nil },
              :body => { 'Tagging' => {
                           'TagSet' => {
              'Tag' => :TagSet } } }

              base.query_api_pattern 'DeleteBucketTagging', :delete, '{:Bucket}',
                :params => { 'tagging' => nil }

              base.query_api_pattern 'GetBucketLifecycle', :get, '{:Bucket}',
                :params => { 'lifecycle' => nil }

              base.query_api_pattern 'PutBucketLifecycle', :put, '{:Bucket}',
                :params => { 'lifecycle' => nil },
              :body => { 'LifecycleConfiguration' => {
              'Rule' => :Rule } }

              base.query_api_pattern 'DeleteBucketLifecycle', :delete, '{:Bucket}',
                :params => { 'lifecycle' => nil }


              #-----------------
              # Object
              #-----------------


              base.query_api_pattern 'DeleteObject', :delete, '{:Bucket}/{:Object}'


              base.query_api_pattern 'DeleteMultipleObjects', :post, '{:Bucket}',
                :params => { 'delete' => nil },
              :body   => { 'Delete' => {
                             'Quiet'             => :Quiet,
                             'Object[{:Object}]' => {
                               'Key'       => :Key,
                               'VersionId' => :VersionId
                             }
                           }
              },
              :defaults => {
                :VersionId => Utils::NONE,
                :Quiet     => Utils::NONE
              },
              :before => Proc.new{ |args| # fix incoming Keys if they were passed as Strings and not as Hashes
                unless args[:params]['Object']._blank?
                  args[:params]['Object'] = Array(args[:params]['Object'])
                  args[:params]['Object'].dup.each_with_index do |object, idx|
                    args[:params]['Object'][idx] = { 'Key' => object } unless object.is_a?(Hash)
                  end
                end
              }


              base.query_api_pattern 'GetObject', :get, '{:Bucket}/{:Object}'


              base.query_api_pattern 'GetObjectAcl', :get, '{:Bucket}/{:Object}',
                :params => { 'acl' => nil }


              base.query_api_pattern 'GetObjectTorrent', :get, '{:Bucket}/{:Object}',
                :params => { 'torrent'=> nil }


              base.query_api_pattern 'HeadObject', :head, '{:Bucket}/{:Object}'


              base.query_api_pattern 'PostObject', :post, '{:Bucket}/{:Object}'


              base.query_api_pattern 'PutObject', :put, '{:Bucket}/{:Object}',
                :body    => Utils::MUST_BE_SET,
                :headers => { 'content-type' => 'application/octet-stream' }


              base.query_api_pattern 'PutObjectAcl', :put, '{:Bucket}/{:Object}',
                :params => { 'acl'=> nil }


              base.query_api_pattern 'PutObjectCannedAcl', :put, '{:Bucket}/{:Object}',
                :params => { 'acl'=> nil }, :headers => { 'x-amz-acl' => :Acl}


              base.query_api_pattern 'CopyObject', :put, '{:DestinationBucket}/{:DestinationObject}',
                :headers => { 'x-amz-copy-source' => '{:SourceBucket}/{:SourceObject}' }


              base.query_api_pattern 'CopyObjectWithMetadata', :put, '{:DestinationBucket}/{:DestinationObject}',
                :headers => { 'x-amz-copy-source'        => '{:SourceBucket}/{:SourceObject}',
                              'x-amz-metadata-directive' => :MetadataDirective },
                :defaults => {
                  :MetadataDirective => 'COPY'
                }


              base.query_api_pattern 'InitiateMultipartUpload', :post, '{:Bucket}/{:Object}',
                :params => { 'uploads' => nil }


              base.query_api_pattern 'UploadPart', :post, '{:Bucket}/{:Object}',
                :params => { 'partNumber' => :PartNumber,
                             'uploadId'   => :UploadId }


              base.query_api_pattern 'UploadPartCopy', :put, '{:DestinationBucket}/{:DestinationObject}',
                :params  => { 'partNumber' => :PartNumber,
                              'uploadId'   => :UploadId },
                :headers => { 'x-amz-copy-source' => '{:SourceBucket}/{:SourceObject}' }


              base.query_api_pattern 'CompleteMultipartUpload', :post, '{:Bucket}/{:Object}',
                :params => { 'uploadId' => :UploadId }


              base.query_api_pattern 'AbortMultipartUpload', :delete, '{:Bucket}/{:Object}',
                :params => { 'uploadId' => :UploadId }


              base.query_api_pattern 'ListParts', :get, '{:Bucket}/{:Object}',
                :params => { 'uploadId' => :UploadId }
            end
          end

        end
      end
    end
  end
end
