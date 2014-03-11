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
      module CF

        # CF wrapper namespace
        module Wrapper

          # Default wrapper
          module DEFAULT
            
            # Defines QUERY API like methods for the service.
            def self.extended(base)

              distribution_config = {
                'DistributionConfig' => {
                  '@xmlns'            => "http://cloudfront.amazonaws.com/doc/2010-11-01/",
                  'S3Origin'          => :S3Origin,
                  'CustomOrigin'      => :CustomOrigin,
                  'CallerReference'   => :CallerReference,
                  'CNAME'             => :CNAME,
                  'Comment'           => :Comment,
                  'Enabled'           => :Enabled,
                  'DefaultRootObject' => :DefaultRootObject,
                  'Logging'           => :Logging,
                  'TrustedSigners'    => :TrustedSigners,
                  'RequiredProtocols{!remove-if-blank}' => {
                    'Protocol' => :Protocol
                  }
                }
              }
              distribution_config_defaults = {
                :S3Origin          => Utils::NONE,
                :CustomOrigin      => Utils::NONE,
                :CNAME             => Utils::NONE,
                :Comment           => Utils::NONE,
                :DefaultRootObject => Utils::NONE,
                :Logging           => Utils::NONE,
                :Protocol          => Utils::NONE,
                :TrustedSigners    => Utils::NONE,
              }

              
              streaming_distribution_config = {
                'StreamingDistributionConfig' => {
                  '@xmlns'          => "http://cloudfront.amazonaws.com/doc/2010-11-01/",
                  'S3Origin'        => :S3Origin,
                  'CallerReference' => :CallerReference,
                  'CNAME'           => :CNAME,
                  'Comment'         => :Comment,
                  'Enabled'         => :Enabled,
                  'Logging'         => :Logging,
                  'TrustedSigners'  => :TrustedSigners
                }
              }
              streaming_distribution_config_defaults = {
                :CNAME             => Utils::NONE,
                :Comment           => Utils::NONE,
                :DefaultRootObject => Utils::NONE,
                :TrustedSigners    => Utils::NONE,
                :Logging           => Utils::NONE
              }

              
              origin_access_identity_config = {
                'CloudFrontOriginAccessIdentityConfig' => {
                  '@xmlns'          => 'http://cloudfront.amazonaws.com/doc/2010-11-01/',
                  'CallerReference' => :CallerReference,
                  'Comment'         => :Comment
                }
              }
              origin_access_identity_defaults = {
               :Comment =>  Utils::NONE                
              } 
              
                            
              #-----------------
              # Distributions
              #-----------------
              
              
              base.query_api_pattern 'ListDistributions', :get, 'distribution'

              
              base.query_api_pattern 'GetDistribution', :get, 'distribution/{:DistributionId}'

              
              base.query_api_pattern 'GetDistributionConfig', :get, 'distribution/{:DistributionId}/config'

              
              base.query_api_pattern 'CreateDistribution', :post, 'distribution',
                :body     => distribution_config,
                :defaults => distribution_config_defaults
              
              
              base.query_api_pattern 'UpdateDistribution', :put, 'distribution/{:DistributionId}/config',
                :body     => distribution_config,
                :defaults => distribution_config_defaults
              
              
              base.query_api_pattern 'DeleteDistribution', :delete, 'distribution/{:DistributionId}'
              
              
              #---------------------------
              # Streaming Distributions
              #--------------------------
              
              
              base.query_api_pattern 'ListStreamingDistributions', :get, 'streaming-distribution'

              
              base.query_api_pattern 'GetStreamingDistribution', :get, 'streaming-distribution/{:DistributionId}'

              
              base.query_api_pattern 'GetStreamingDistributionConfig', :get, 'streaming-distribution/{:DistributionId}/config'

              
              base.query_api_pattern 'CreateStreamingDistribution', :post, 'streaming-distribution',
                :body     => streaming_distribution_config,
                :defaults => streaming_distribution_config_defaults
              
              
              base.query_api_pattern 'UpdateStreamingDistribution', :put, 'streaming-distribution/{:DistributionId}/config',
                :body     => streaming_distribution_config,
                :defaults => streaming_distribution_config_defaults
              
              
              base.query_api_pattern 'DeleteStreamingDistribution', :delete, 'streaming-distribution/{:DistributionId}'
              
              
              #---------------------------
              # Origin Access Identities
              #--------------------------
              
              
              base.query_api_pattern 'ListOriginAccessIdentities', :get, 'origin-access-identity/cloudfront'
              
              
              base.query_api_pattern 'GetOriginAccessIdentity', :get, 'origin-access-identity/cloudfront/{:IdentityId}'
              
              
              base.query_api_pattern 'GetOriginAccessIdentityConfig', :get, 'origin-access-identity/cloudfront/{:IdentityId}/config'
              
              
              base.query_api_pattern 'CreateOriginAccessIdentity', :post, 'origin-access-identity/cloudfront',
                :body     => origin_access_identity_config,
                :defaults => origin_access_identity_defaults
              
              
              base.query_api_pattern 'UpdateOriginAccessIdentity', :pup, 'origin-access-identity/cloudfront/{:IdentityId}/config',
                :body     => origin_access_identity_config,
                :defaults => origin_access_identity_defaults
              
              
              base.query_api_pattern 'DeleteOriginAccessIdentity', :delete, 'origin-access-identity/cloudfront/{:IdentityId}'
              

              #---------------------------
              # Origin Access Identities
              #--------------------------
              
              
              base.query_api_pattern 'ListInvalidations', :get,  'distribution/{:DistributionId}/invalidation'

              
              base.query_api_pattern 'GetInvalidation', :get,  'distribution/{:DistributionId}/invalidation/{:InvalidationId}'

              
              base.query_api_pattern 'CreateInvalidation', :post,  'distribution/{:DistributionId}/invalidation',
                :body => {
                  'InvalidationBatch' => {
                    'CallerReference' => :CallerReference,
                    'Path'            => :Path
                  }
                }
              
            end
            
          end          
        end
      end
    end
  end
end