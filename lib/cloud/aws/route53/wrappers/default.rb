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
            
            # Defines QUERY API like methods for the service.
            def self.extended(base)

              #-----------------
              # Hosted Zones
              #-----------------
              
              
              base.query_api_pattern 'ListHostedZones', :get, 'hostedzone'

              
              base.query_api_pattern 'GetHostedZone', :get, 'hostedzone/{:HostedZoneId}'


              base.query_api_pattern 'CreateHostedZones', :post, 'hostedzone',
                :body => {
                  'CreateHostedZoneRequest' => {
                    'Name'             => :Name,
                    'CallerReference'  => :CallerReference,
                    'HostedZoneConfig{!remove-if-blank}' => {
                      'Comment' => :Comment
                    }
                  }
                },
                :defaults => {
                  :Comment => Utils::NONE
                }
              
              
              base.query_api_pattern 'DeleteHostedZone', :delete, 'hostedzone/{:HostedZoneId}'
              

              #----------------------
              # Resource Record Sets
              #----------------------

              
              base.query_api_pattern 'ListResourceRecordSets', :get, 'hostedzone/{:HostedZoneId}/rrset'
              

              base.query_api_pattern 'GetChange', :get, 'change/{:ChangeId}'
              
              
              base.query_api_pattern 'ChangeResourceRecordSets', :post, 'hostedzone/{:HostedZoneId}/rrset',
                :body => {
                  'ChangeResourceRecordSetsRequest' => {
                    '@xmlns'      => 'https://route53.amazonaws.com/doc/2011-05-05/',
                    'ChangeBatch' => {
                      'Comment' => :Comment,
                      'Changes' => {
                        'Change[{:Change}]' => {
                          'Action'            => :Action,
                          'ResourceRecordSet' => {
                            'Name' => :Name,
                            'Type' => :Type,
                            'AliasTarget{!remove-if-blank}' => {
                              'HostedZoneId' => :HostedZoneId,
                              'DNSName'      => :DNSName
                            },
                            'SetIdentifier' => :SetIdentifier,
                            'Weight'        => :Weight,
                            'TTL'           => :TTL,
                            'ResourceRecords{!remove-if-blank}' => {
                              'ResourceRecord{!remove-if-blank}' => {
                                'Value' => :ResourceRecord
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                },
                :defaults => {
                  :Comment        => Utils::NONE,
                  :TTL            => Utils::NONE,
                  :DNSName        => Utils::NONE,
                  :HostedZoneId   => Utils::NONE,
                  :SetIdentifier  => Utils::NONE,
                  :Weight         => Utils::NONE,
                  :ResourceRecord => Utils::NONE
                }
              
              
            end
            
          end          
        end
      end
    end
  end
end