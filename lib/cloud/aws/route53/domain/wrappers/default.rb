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
        module Domain

          # Route 53 Domain wrapper namespace
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

                #----------------------
                # Domain Registration
                #----------------------

                # Attention: host: route53domains.us-east-1.amazonaws.com

                base.query_api_pattern 'CheckDomainAvailability', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.CheckDomainAvailability'
                  },
                  :body => {
                    'DomainName' => :DomainName
                  }

                base.query_api_pattern 'RegisterDomain', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.RegisterDomain'
                  },
                  :body => {
                    'DomainName'                         => :DomainName,
                    'DurationInYears'                    => :DurationInYears,
                    'AutoRenew'                          => :AutoRenew,
                    'RegistrantContact'                  => :RegistrantContact,
                    'AdminContact'                       => :AdminContact,
                    'TechContact'                        => :TechContact,
                    'PrivacyProtectionRegistrantContact' => :PrivacyProtectionRegistrantContact,
                    'PrivacyProtectionAdminContact'      => :PrivacyProtectionAdminContact,
                    'PrivacyProtectionTechContact'       => :PrivacyProtectionTechContact
                  },
                  :defaults => {
                    :AutoRenew                          => Utils::NONE,
                    :PrivacyProtectionRegistrantContact => Utils::NONE,
                    :PrivacyProtectAdminContact         => Utils::NONE,
                    :PrivacyProtectTechContact          => Utils::NONE
                  }

                base.query_api_pattern 'UpdateDomainContact', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.UpdateDomainContact'
                  },
                  :body => {
                    'DomainName'        => :DomainName,
                    'RegistrantContact' => :RegistrantContact,
                    'AdminContact'      => :AdminContact,
                    'TechContact'       => :TechContact
                  }

                base.query_api_pattern 'UpdateDomainNameservers', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.UpdateDomainNameservers'
                  },
                  :body => {
                    'DomainName'  => :DomainName,
                    'Nameservers' => :Nameservers
                  }

                base.query_api_pattern 'UpdateDomainContactPrivacy', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.UpdateDomainContactPrivacy'
                  },
                  :body => {
                    'DomainName'        => :DomainName,
                    'AdminPrivacy'      => :AdminPrivacy,
                    'RegistrantPrivacy' => :RegistrantPrivacy,
                    'TechPrivacy'       => :TechPrivacy
                  },
                  :defaults => {
                    :AdminPrivacy      => Utils::NONE,
                    :RegistrantPrivacy => Utils::NONE,
                    :TechPrivacy       => Utils::NONE
                  }

                base.query_api_pattern 'EnableDomainAutoRenew', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.EnableDomainAutoRenew'
                  },
                  :body => {
                    'DomainName' => :DomainName
                  }

                base.query_api_pattern 'DisableDomainAutoRenew', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.DisableDomainAutoRenew'
                  },
                  :body => {
                    'DomainName' => :DomainName
                  }

                base.query_api_pattern 'ListDomains', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.ListDomains'
                  },
                  :body => {
                    'Marker'   => :Marker,
                    'MaxItems' => :MaxItems
                  },
                  :defaults => {
                    :Marker   => Utils::NONE,
                    :MaxItems => Utils::NONE
                  }

                base.query_api_pattern 'GetDomainDetail', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.GetDomainDetail'
                  },
                  :body => {
                    'DomainName' => :DomainName
                  }

                base.query_api_pattern 'ListOperations', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.ListOperations'
                  },
                  :body => {
                    'Marker'   => :Marker,
                    'MaxItems' => :MaxItems
                  },
                  :defaults => {
                    :Marker   => Utils::NONE,
                    :MaxItems => Utils::NONE
                  }


                base.query_api_pattern 'GetOperationDetail', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.GetOperationDetail'
                  },
                  :body => {
                    'OperationId' => :OperationId
                  }

                base.query_api_pattern 'DisableDomainTransferLock', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.DisableDomainTransferLock'
                  },
                  :body => {
                    'DomainName' => :DomainName
                  }

                base.query_api_pattern 'EnableDomainTransferLock', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.EnableDomainTransferLock'
                  },
                  :body => {
                    'DomainName' => :DomainName
                  }

                base.query_api_pattern 'RetrieveDomainAuthCode', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.RetrieveDomainAuthCode'
                  },
                  :body => {
                    'DomainName' => :DomainName
                  }

                base.query_api_pattern 'TransferDomain', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.TransferDomain'
                  },
                  :body => {
                    'DomainName'                         => :DomainName,
                    'DurationInYears'                    => :DurationInYears,
                    'AuthCode'                           => :AuthCode,
                    'AutoRenew'                          => :AutoRenew,
                    'RegistrantContact'                  => :RegistrantContact,
                    'AdminContact'                       => :AdminContact,
                    'TechContact'                        => :TechContact,
                    'PrivacyProtectionRegistrantContact' => :PrivacyProtectionRegistrantContact,
                    'PrivacyProtectionAdminContact'      => :PrivacyProtectionAdminContact,
                    'PrivacyProtectionTechContact'       => :PrivacyProtectionTechContact
                  },
                  :defaults => {
                    :AutoRenew                          => Utils::NONE,
                    :PrivacyProtectionRegistrantContact => Utils::NONE,
                    :PrivacyProtectAdminContact         => Utils::NONE,
                    :PrivacyProtectTechContact          => Utils::NONE
                  }

                #----------------------
                # Actions on Tags for Domains
                #----------------------

                base.query_api_pattern 'UpdateTagsForDomains', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.UpdateTagsForDomains'
                  },
                  :body => {
                    'DomainName'   => :DomainName,
                    'TagsToUpdate' => :TagsToUpdate
                  }

                base.query_api_pattern 'ListTagsForDomain', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.ListTagsForDomain'
                  },
                  :body => {
                    'DomainName' => :DomainName
                  }

                base.query_api_pattern 'DeleteTagsForDomain', :post, '',
                  :headers => {
                    'content-type' => 'application/x-amz-json-1.1',
                    'x-amz-target' => 'Route53Domains_v20140515.DeleteTagsForDomain'
                  },
                  :body => {
                    'DomainName'   => :DomainName,
                    'TagsToDelete' => :TagsToDelete
                  }

              end
            end
          end
        end
      end
    end
  end
end