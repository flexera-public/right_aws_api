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


            # Defines QUERY API like methods for the service
            #
            # @return [void]
            #
            # @example
            #  # no example
            #
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
                :params => { 'policy' => '' }


              base.query_api_pattern 'DeleteBucketWebsite', :delete, '{:Bucket}',
                :params => { 'website' => '' }


              base.query_api_pattern 'ListObjects', :get, '{:Bucket}'
              base.query_api_pattern 'GetBucket', :get, '{:Bucket}' # alias for ListObjects


              base.query_api_pattern 'GetBucketAcl', :get, '{:Bucket}',
                :params => { 'acl'=> '' }


              base.query_api_pattern 'GetBucketPolicy',  :get, '{:Bucket}',
                :params => { 'policy'=> '' }


              base.query_api_pattern 'GetBucketLocation',  :get, '{:Bucket}',
                :params => { 'location'=> '' }


              base.query_api_pattern 'GetBucketLogging',  :get, '{:Bucket}',
                :params => { 'logging'=> '' }


              base.query_api_pattern 'GetBucketNotification', :get, '{:Bucket}',
                :params => { 'notification'=> '' }


              base.query_api_pattern 'GetBucketVersions',  :get, '{:Bucket}',
                :params => { 'versions'=> '' }


              base.query_api_pattern 'GetBucketRequestPayment', :get, '{:Bucket}',
                :params => { 'requestPayment'=> '' }


              base.query_api_pattern 'GetBucketVersioning', :get, '{:Bucket}',
                :params => { 'versioning'=> '' }


              base.query_api_pattern 'GetBucketWebsite', :get, '{:Bucket}',
                :params => { 'website'=> '' }


              base.query_api_pattern 'ListMultipartUploads',  :get, '{:Bucket}',
                :params => { 'uploads'=> '' }


              base.query_api_pattern 'PutBucket', :put, '{:Bucket}'


              base.query_api_pattern 'PutBucketAcl', :put, '{:Bucket}',
                :params  => { 'acl' => '' },
                :body    => { 'AccessControlPolicy' => :AccessControlPolicy },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'PutBucketPolicy', :put, '{:Bucket}',
                :params  => { 'policy' => '' },
                :body    => Utils::MUST_BE_SET,
                :headers => { 'content-type' => 'application/json' }


              base.query_api_pattern 'PutBucketLogging', :put, '{:Bucket}',
                :params  => { 'logging' => '' },
                :body    => { 'BucketLoggingStatus' => :BucketLoggingStatus },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'PutBucketNotification', :put, '{:Bucket}',
                :params  => { 'notification' => '' },
                :body    => { 'NotificationConfiguration' => :NotificationConfiguration },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'PutBucketRequestPayment', :put, '{:Bucket}',
                :params => { 'requestPayment' => '' },
                :body   => { 'RequestPaymentConfiguration' => :RequestPaymentConfiguration },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'PutBucketVersioning', :put, '{:Bucket}',
                :params  => { 'versioning' => '' },
                :body    => { 'VersioningConfiguration' => :VersioningConfiguration },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'PutBucketWebsite', :put, '{:Bucket}',
                :params  => { 'website' => '' },
                :body    => { 'WebsiteConfiguration' => :WebsiteConfiguration },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'GetBucketCors', :get, '{:Bucket}',
                :params => { 'cors'=> '' }


              base.query_api_pattern 'DeleteBucketCors',  :delete, '{:Bucket}',
                :params => { 'cors'=> '' }


              base.query_api_pattern 'PutBucketCors',  :put, '{:Bucket}',
                :params  => { 'cors'=> '' },
                :body    => { 'CORSConfiguration' => { 'CORSRule' => :CORSRule } },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'GetBucketTagging', :get, '{:Bucket}',
                :params => { 'tagging' => '' }


              base.query_api_pattern 'PutBucketTagging', :put, '{:Bucket}',
                :params  => { 'tagging' => '' },
                :body    => { 'Tagging' => { 'TagSet' => { 'Tag' => :TagSet } } },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'DeleteBucketTagging', :delete, '{:Bucket}',
                :params => { 'tagging' => '' }


              base.query_api_pattern 'GetBucketLifecycle', :get, '{:Bucket}',
                :params => { 'lifecycle' => '' }


              base.query_api_pattern 'PutBucketLifecycle', :put, '{:Bucket}',
                :params  => { 'lifecycle' => '' },
                :body    => { 'LifecycleConfiguration' => { 'Rule' => :Rule } },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'DeleteBucketLifecycle', :delete, '{:Bucket}',
                :params => { 'lifecycle' => '' }


              #-----------------
              # Object
              #-----------------


              base.query_api_pattern 'DeleteObject', :delete, '{:Bucket}/{:Object}'


              base.query_api_pattern 'DeleteMultipleObjects', :post, '{:Bucket}',
                :params => { 'delete' => '' },
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


              base.query_api_pattern 'GetObject', :get, '{:Bucket}/{:Object}',
                :options => { :raw_response => true }


              base.query_api_pattern 'GetObjectAcl', :get, '{:Bucket}/{:Object}',
                :params => { 'acl' => '' }


              base.query_api_pattern 'GetObjectTorrent', :get, '{:Bucket}/{:Object}',
                :params => { 'torrent'=> '' }


              base.query_api_pattern 'HeadObject', :head, '{:Bucket}/{:Object}'


              base.query_api_pattern 'PostObject', :post, '{:Bucket}/{:Object}'


              base.query_api_pattern 'PutObject', :put, '{:Bucket}/{:Object}',
                :body    => Utils::MUST_BE_SET,
                :headers => { 'content-type' => 'application/octet-stream' }


              base.query_api_pattern 'PutObjectAcl', :put, '{:Bucket}/{:Object}',
                :params  => { 'acl'=> '' },
                :body    => { 'AccessControlPolicy' => :AccessControlPolicy },
                :headers => { 'content-type' => 'application/xml'}


              base.query_api_pattern 'PutObjectCannedAcl', :put, '{:Bucket}/{:Object}',
                :params  => { 'acl' => '' },
                :headers => { 'x-amz-acl' => :Acl, 'content-type' => 'application/xml'}


              base.query_api_pattern 'CopyObject', :put, '{:DestinationBucket}/{:DestinationObject}',
                :headers => { 'x-amz-copy-source' => '{:SourceBucket}/{:SourceObject}' }


              base.query_api_pattern 'CopyObjectWithMetadata', :put, '{:DestinationBucket}/{:DestinationObject}',
                :headers => { 'x-amz-copy-source'        => '{:SourceBucket}/{:SourceObject}',
                              'x-amz-metadata-directive' => :MetadataDirective },
                :defaults => {
                  :MetadataDirective => 'COPY'
                }


              base.query_api_pattern 'InitiateMultipartUpload', :post, '{:Bucket}/{:Object}',
                :params => { 'uploads' => '' }


              base.query_api_pattern 'UploadPart', :post, '{:Bucket}/{:Object}',
                :params  => { 'partNumber' => :PartNumber,
                              'uploadId'   => :UploadId },
                :headers => { 'content-type' => 'application/octet-stream' }


              base.query_api_pattern 'UploadPartCopy', :put, '{:DestinationBucket}/{:DestinationObject}',
                :params  => { 'partNumber' => :PartNumber,
                              'uploadId'   => :UploadId },
                :headers => { 'x-amz-copy-source' => '{:SourceBucket}/{:SourceObject}' }


              base.query_api_pattern 'CompleteMultipartUpload', :post, '{:Bucket}/{:Object}',
                :params  => { 'uploadId' => :UploadId },
                :body    => { 'CompleteMultipartUpload' => :CompleteMultipartUpload },
                :headers => { 'x-amz-acl' => :Acl, 'content-type' => 'application/xml'}


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
