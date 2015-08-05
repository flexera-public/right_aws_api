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
      module Route53

        # Route 53 wrapper namespace
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
              # Hosted Zones
              #-----------------

              base.query_api_pattern 'CreateHostedZone', :post, 'hostedzone',
                :body => {
                  'CreateHostedZoneRequest' => {
                    'Name'             => :Name,
                    'CallerReference'  => :CallerReference,
                    'HostedZoneConfig{!remove-if-blank}' => {
                      'Comment' => :Comment
                    },
                    'DelegationSetId' => :DelegationSetId,
                    'VPC{!remove-if-blank}' => {
                      'VPCId'     => :VPCId,
                      'VPCRegion' => :VPCRegion
                    }
                  }
                },
                :defaults => {
                  :Comment         => Utils::NONE,
                  :DelegationSetId => Utils::NONE,
                  :VPCId           => Utils::NONE,
                  :VPCRegion       => Utils::NONE
                }

              base.query_api_pattern 'ListHostedZone', :get, 'hostedzone'

              base.query_api_pattern 'ListHostedZonesByName', :get, 'hostedzonesbyname'

              base.query_api_pattern 'GetHostedZone', :get, 'hostedzone/{:HostedZoneId}'

              base.query_api_pattern 'GetHostedZoneCount', :get, 'hostedzonecount'

              base.query_api_pattern 'UpdateHostedZoneComment', :post, 'hostedzone/{:HostedZoneId}',
                :body => {
                  'UpdateHostedZoneCommentRequest' => {
                    'Comment' => :Comment
                  }
                }

              base.query_api_pattern 'AssociateVPCWithHostedZone', :post, 'hostedzone/{:HostedZoneId}/associatevpc',
                :body => {
                  'AssociateVPCWithHostedZoneRequest' => {
                    'VPC{!remove-if-blank}' => {
                      'VPCId'     => :VPCId,
                      'VPCRegion' => :VPCRegion
                    },
                    'Comment' => :Comment
                  }
                },
                :defaults => {
                  :Comment => Utils::NONE,
                }

              base.query_api_pattern 'DisassociateVPCFromHostedZone', :post, 'hostedzone/{:HostedZoneId}/disassociatevpc',
                :body => {
                  'DisassociateVPCFromHostedZoneRequest' => {
                    'VPC{!remove-if-blank}' => {
                      'VPCId'     => :VPCId,
                      'VPCRegion' => :VPCRegion
                    },
                    'Comment' => :Comment
                  }
                },
                :defaults => {
                  :Comment => Utils::NONE,
                }

              base.query_api_pattern 'DeleteHostedZone', :delete, 'hostedzone/{:HostedZoneId}'

              #----------------------
              # Resource Record Sets
              #----------------------

              base.query_api_pattern 'ListResourceRecordSets', :get, 'hostedzone/{:HostedZoneId}/rrset'

              base.query_api_pattern 'GetChange', :get, 'change/{:ChangeId}'

              base.query_api_pattern 'GetGeoLocation', :get, 'geolocation'

              base.query_api_pattern 'ListGeoLocations', :get, 'geolocations'

              base.query_api_pattern 'ChangeResourceRecordSets', :post, 'hostedzone/{:HostedZoneId}/rrset',
                :body => {
                  'ChangeResourceRecordSetsRequest' => {
                    '@xmlns'      => 'https://route53.amazonaws.com/doc/2013-04-01/',
                    'ChangeBatch' => {
                      'Comment' => :Comment,
                      'Changes' => {
                        'Change[{:Change}]' => {
                          'Action'            => :Action,
                          'ResourceRecordSet' => {
                            'Name' => :Name,
                            'Type' => :Type,
                            'AliasTarget{!remove-if-blank}' => {
                              'HostedZoneId'         => :TargetHostedZoneId,
                              'DNSName'              => :DNSName,
                              'EvaluateTargetHealth' => :EvaluateTargetHealth
                            },
                            'GeoLocation{!remove-if-blank}' => {
                              'ContinentCode'   => :ContinentCode,
                              'CountryCode'     => :CountryCode,
                              'SubdivisionCode' => :SubdivisionCode
                            },
                            'SetIdentifier' => :SetIdentifier,
                            'Weight'        => :Weight,
                            'TTL'           => :TTL,
                            'Failover'      => :Failover,
                            'ResourceRecords{!remove-if-blank}' => {
                              'ResourceRecord{!remove-if-blank}' => {
                                'Value' => :ResourceRecord
                              }
                            },
                            'HealthCheckId' => :HealthCheckId
                          }
                        }
                      }
                    }
                  }
                },
                :defaults => {
                  :Comment              => Utils::NONE,
                  :TTL                  => Utils::NONE,
                  :DNSName              => Utils::NONE,
                  :TargetHostedZoneId   => Utils::NONE,
                  :SetIdentifier        => Utils::NONE,
                  :Weight               => Utils::NONE,
                  :ResourceRecord       => Utils::NONE,
                  :HealthCheckId        => Utils::NONE,
                  :EvaluateTargetHealth => Utils::NONE,
                  :Failover             => Utils::NONE,
                  :ContinentCode        => Utils::NONE,
                  :CountryCode          => Utils::NONE,
                  :SubdivisionCode      => Utils::NONE
                }

              #----------------------
              # Reusable Delegation Sets
              #----------------------

              base.query_api_pattern 'CreateReusableDelegationSet', :post, 'delegationset',
                :body => {
                  'CreateReusableDelegationSetRequest' => {
                    'CallerReference' => :CallerReference,
                    'HostedZoneId'    => :HostedZoneId
                  }
                }

              base.query_api_pattern 'ListReusableDelegationSets', :get, 'delegationset'

              base.query_api_pattern 'GetReusableDelegationSet', :get, 'delegationset/{:ReusableDelegationSetId}'

              base.query_api_pattern 'DeleteReusableDelegationSet', :delete, 'delegationset/{:ReusableDelegationSetId}'

              #----------------------
              # Health Check
              #----------------------

              base.query_api_pattern 'CreateHealthCheck', :post, 'healthcheck',
                :body => {
                  'CreateHealthCheckRequest' => {
                    'CallerReference' => :CallerReference,
                    'HealthCheckConfig' => {
                      'IPAddress'                => :IPAddress,
                      'Port'                     => :Port,
                      'Type'                     => :Type,
                      'FullyQualifiedDomainName' => :FullyQualifiedDomainName,
                      'SearchString'             => :SearchString,
                      'RequestInterval'          => :RequestInterval,
                      'FailureThreshold'         => :FailureThreshold
                    }
                  }
                },
                :defaults => {
                  :IPAddress                => Utils::NONE,
                  :Port                     => Utils::NONE,
                  :ResourcePath             => Utils::NONE,
                  :FullyQualifiedDomainName => Utils::NONE,
                  :SearchString             => Utils::NONE,
                  :RequestInterval          => Utils::NONE,
                  :FailureThreshold         => Utils::NONE,
                }

              base.query_api_pattern 'UpdateHealthCheck', :post, 'healthcheck/{:HealthCheckId}',
                :body => {
                  'CreateHealthCheckRequest' => {
                    'HealthCheckVersion'       => :HealthCheckVersion,
                    'IPAddress'                => :IPAddress,
                    'Port'                     => :Port,
                    'FullyQualifiedDomainName' => :FullyQualifiedDomainName,
                    'SearchString'             => :SearchString,
                    'RequestInterval'          => :RequestInterval,
                    'FailureThreshold'         => :FailureThreshold
                  }
                },
                :defaults => {
                  :IPAddress                => Utils::NONE,
                  :Port                     => Utils::NONE,
                  :ResourcePath             => Utils::NONE,
                  :FullyQualifiedDomainName => Utils::NONE,
                  :SearchString             => Utils::NONE,
                  :RequestInterval          => Utils::NONE,
                  :FailureThreshold         => Utils::NONE,
                }

              base.query_api_pattern 'ListHealthChecks', :get, 'healthcheck'

              base.query_api_pattern 'GetHealthCheck', :get, 'healthcheck/{:HealthCheckId}'

              base.query_api_pattern 'GetHealthCheckStatus', :get, 'healthcheck/{:HealthCheckId}/status'

              base.query_api_pattern 'GetHealthCheckLastFailureReason', :get, 'healthcheck/{:HealthCheckId}/lastfailurereason'

              base.query_api_pattern 'GetCheckerIpRanges', :get, 'checkeripranges'

              base.query_api_pattern 'GetHealthCheckCount', :get, 'healthcheckcount'

              base.query_api_pattern 'DeleteHealthCheck', :delete, 'healthcheck/{:HealthCheckId}'

              #----------------------
              # Tags for Hosted Zones and Health Checks
              #----------------------

              base.query_api_pattern 'ChangeTagsForResource', :post, 'tags/{:ResourceType}/{:ResourceId}',
                :body => {
                  'ChangeTagsForResourceRequest' => {
                    'RemoveTagKeys' => :RemoveTagKeys,
                    'AddTags{!remove-if-blank}' => {
                      'Tag' => :Tag
                    }
                  }
                },
                :defaults => {
                  :RemoveTagKeys => Utils::NONE,
                  :Tag           => Utils::NONE
                }

              base.query_api_pattern 'ListTagsForResource', :get, 'tags/{:ResourceType}/{:ResourceId}'

              base.query_api_pattern 'ListTagsForResources', :get, 'tags/{:ResourceType}',
                :body => {
                  'ListTagsForResourcesRequest' => {
                    'ResourceIds' => {
                      'ResourceId' => :ResourceId
                    }
                  }
                }

            end
          end
        end
      end
    end
  end
end