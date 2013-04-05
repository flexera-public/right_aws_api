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
    module Utils
      module AWS

        @@digest1   = OpenSSL::Digest::Digest.new("sha1")
        @@digest256 = nil
        if OpenSSL::OPENSSL_VERSION_NUMBER > 0x00908000
          @@digest256 = OpenSSL::Digest::Digest.new("sha256") rescue nil # Some installations may not support sha256
        end

        # Generates a signature for the given string, secret access key and digest.
        #
        # @param [String] aws_secret_access_key
        # @param [String] auth_string
        # @param [String] digest
        #
        # @return [String] The signature.
        #
        # @example
        #   RightScale::CloudApi::Utils::AWS.sign('my-secret-key', 'something-that-needs-to-be-signed') #=>
        #     'kdHo0Ks4KkypU1CkYZzAxFIIX+0='
        #
        def self.sign(aws_secret_access_key, auth_string, digest=nil)
          Utils::base64en(OpenSSL::HMAC.digest(digest || @@digest1, aws_secret_access_key, auth_string))
        end

        # Returns ISO-8601 representation for the given time.
        #
        # @param [Time,Fixnum] time
        # @return [String]
        #
        # @example
        #  RightScale::CloudApi::Utils::AWS.utc_iso8601(Time.now) #=> '2013-03-22T21:00:21.000Z'
        #
        # @example
        #  RightScale::CloudApi::Utils::AWS.utc_iso8601(0) #=> '1970-01-01T00:00:00.000Z'
        #
        def self.utc_iso8601(time)
          case
          when time.is_a?(Fixnum) then Time::at(time)
          when time.is_a?(String) then Time::parse(time)
          else                         time
          end.utc.strftime("%Y-%m-%dT%H:%M:%S.000Z")
        end

        # Escapes a string accordingly to Amazon rules.
        # @see http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/MakingRESTRequests.html
        #
        # @param [String] string
        # @return [String]
        #
        # @example
        #   RightScale::CloudApi::Utils::AWS.amz_escape('something >= 13') #=> 'something%20%3E%3D%2013'
        #
        def self.amz_escape(string)
          string.to_s.gsub(/([^a-zA-Z0-9._~-]+)/n) { '%' + $1.unpack('H2' * $1.size).join('%').upcase }
        end

        # Signature Version 2.
        # EC2, SQS and SDB requests must be signed by this guy.
        #
        # @see http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/MakingRESTRequests.html
        # @see http://aws.amazon.com/articles/1928?_encoding=UTF8&jiveRedirect=1
        #
        def self.sign_v2_signature(aws_secret_access_key, params, verb, host, urn)
          params["Timestamp"]      ||= utc_iso8601(Time.now) unless params["Expires"]
          params["SignatureVersion"] = '2'
          # select a signing method (make an old openssl working with sha1)
          # make 'HmacSHA256' to be a default one
          params['SignatureMethod'] = 'HmacSHA256' unless ['HmacSHA256', 'HmacSHA1'].include?(params['SignatureMethod'])
          params['SignatureMethod'] = 'HmacSHA1'   unless @@digest256
          # select a digest
          digest = (params['SignatureMethod'] == 'HmacSHA256' ? @@digest256 : @@digest1)
          # form string to sign
          canonical_string = Utils::params_to_urn(params){ |value| amz_escape(value) }
          string_to_sign = "#{verb.to_s.upcase}\n" +
                           "#{host.downcase}\n"    +
                           "#{urn}\n"              +
                           "#{canonical_string}"
          "#{canonical_string}&Signature=#{amz_escape(sign(aws_secret_access_key, string_to_sign, digest))}"
        end

        # Returns +true+ if the provided bucket name is  a DNS compliant bucket name.
        #
        # @see http://docs.aws.amazon.com/AmazonS3/2006-03-01/dev/BucketRestrictions.html
        #
        # @param [String] bucket_name
        # @return [Boolean]
        #
        # @example
        #   RightScale::CloudApi::Utils::AWS.is_dns_bucket?('my') #=> false
        #
        # @example
        #   RightScale::CloudApi::Utils::AWS.is_dns_bucket?('my_bycket') #=> false
        #
        # @example
        #   RightScale::CloudApi::Utils::AWS.is_dns_bucket?('my-bucket') #=> true
        #
        def self.is_dns_bucket?(bucket_name)
          bucket_name = bucket_name.to_s
          return false unless (3..63) === bucket_name.size
          bucket_name.split('.').each do |component|
            return false unless component[/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/]
          end
          true
        end

        # Signs and Authenticates REST Requests.
        #
        # @see http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html
        #
        def self.sign_s3_signature(aws_secret_access_key, verb, canonicalized_resource, _headers={})
          headers = {}
          # Make sure all our headers ara downcased
          _headers.each do |key, value|
            headers[key.to_s.downcase] = value.is_a?(Array) ? value.join(',') : value
          end
          content_md5                 = headers['content-md5']
          content_type                = headers['content-type']
          date                        = headers['x-amz-date'] || headers['date'] || headers['expires']
          canonicalized_x_amz_headers = headers.select{|key, value|  key[/^x-amz-/]}.sort.map{|key, value| "#{key}:#{value}"}.join("\n")
          canonicalized_x_amz_headers << "\n" unless canonicalized_x_amz_headers._blank?
          # StringToSign
          string_to_sign = "#{verb.to_s.upcase}\n"         +
                           "#{content_md5}\n"              +
                           "#{content_type}\n"             +
                           "#{date}\n"                     +
                           "#{canonicalized_x_amz_headers}"+
                           "#{canonicalized_resource}"
          sign(aws_secret_access_key, string_to_sign)
        end

                    
        # Parametrizes data to the format that Amazon EC2 (and compatible) loves.
        #
        # @example
        #   # Where hash is:
        #   { Name.?.Mask  => Value | [ Values ],
        #     NamePrefix.? => [{ SubNameA.1 => ValueA.1,  SubNameB.1 => ValueB.1 },   # any simple parameter
        #                     ..., 
        #                      { SubNameN.X => ValueN.X,  SubNameM.X => ValueN.X }]   # see BlockDeviceMapping case
        #
        # @example
        #  parametrize( 'ParamA'             => 'a',
        #               'ParamB'             => ['b', 'c'],
        #               'ParamC.?.Something' => ['d', 'e'],
        #               'Filter'             => [ { 'Key' => 'A', 'Value' => ['aa','ab']},
        #                                         { 'Key' => 'B', 'Value' => ['ba','bb']}] ) #=>
        #    {
        #      "Filter.1.Key"       => "A",
        #      "Filter.1.Value.1"   => "aa",
        #      "Filter.1.Value.2"   => "ab",
        #      "Filter.2.Key"       => "B",
        #      "Filter.2.Value.1"   => "ba",
        #      "Filter.2.Value.2"   => "bb",
        #      "ParamA"             => "a",
        #      "ParamB.1"           => "b",
        #      "ParamB.2"           => "c",
        #      "ParamC.1.Something" => "d",
        #      "ParamC.2.Something" => "e"
        #    }
        #
        # @example
        #  # BlockDeviceMapping example
        #  parametrize( 'ImageId'  => 'i-01234567',
        #               'MinCount' => 1,
        #               'MaxCount' => 2,
        #               'KeyName'  => 'my-key',
        #               'SecurityGroupId' => ['sg-01234567', 'sg-12345670', 'sg-23456701'],
        #               'BlockDeviceMapping' => [ 
        #                  { 'DeviceName'     => '/dev/sda1', 
        #                    'Ebs.SnapshotId' => 'snap-01234567', 
        #                    'Ebs.VolumeSize' => 20,
        #                    'Ebs.DeleteOnTermination' => true },
        #                  { 'DeviceName'     => '/dev/sdb1', 
        #                    'Ebs.SnapshotId' => 'snap-12345670', 
        #                    'Ebs.VolumeSize' => 10,
        #                    'Ebs.DeleteOnTermination' => false } ] ) #=> 
        #    {
        #      "BlockDeviceMapping.1.DeviceName"              => "/dev/sda1",
        #      "BlockDeviceMapping.1.Ebs.DeleteOnTermination" => true,
        #      "BlockDeviceMapping.1.Ebs.SnapshotId"          => "snap-01234567",
        #      "BlockDeviceMapping.1.Ebs.VolumeSize"          => 20,
        #      "BlockDeviceMapping.2.DeviceName"              => "/dev/sdb1",
        #      "BlockDeviceMapping.2.Ebs.DeleteOnTermination" => false,
        #      "BlockDeviceMapping.2.Ebs.SnapshotId"          => "snap-12345670",
        #      "BlockDeviceMapping.2.Ebs.VolumeSize"          => 10,
        #      "ImageId"                                      => "i-01234567",
        #      "KeyName"                                      => "my-key",
        #      "MaxCount"                                     => 2,
        #      "MinCount"                                     => 1,
        #      "SecurityGroupId.1"                            => "sg-01234567",
        #      "SecurityGroupId.2"                            => "sg-12345670",
        #      "SecurityGroupId.3"                            => "sg-23456701"
        #    }          
        #
        # @example
        #  parametrize( 'DomainName' => 'kdclient',
        #               'Item' => [ { 'ItemName'  => 'konstantin',
        #                             'Attribute' => [ { 'Name' => 'sex',    'Value' => 'male' },
        #                                              { 'Name' => 'age',    'Value' => '38'} ] },
        #                           { 'ItemName'  => 'alex',
        #                             'Attribute' => [ { 'Name' => 'sex',    'Value' => 'male' },
        #                                              { 'Name' => 'weight', 'Value' => '188'},
        #                                              { 'Name' => 'age',    'Value' => '42'} ] },
        #                           { 'ItemName'  => 'diana',
        #                             'Attribute' => [ { 'Name' => 'sex',    'Value' => 'female' },
        #                                              { 'Name' => 'weight', 'Value' => '120'},
        #                                              { 'Name' => 'age',    'Value' => '25'} ] } ] ) #=> 
        #    { "DomainName"               => "kdclient",
        #      "Item.1.ItemName"          => "konstantin",
        #      "Item.1.Attribute.1.Name"  => "sex",
        #      "Item.1.Attribute.1.Value" => "male",
        #      "Item.1.Attribute.2.Name"  => "weight",
        #      "Item.1.Attribute.2.Value" => "170",
        #      "Item.1.Attribute.3.Name"  => "age",
        #      "Item.1.Attribute.3.Value" => "38",
        #      "Item.2.ItemName"          => "alex",
        #      "Item.2.Attribute.1.Name"  => "sex",
        #      "Item.2.Attribute.1.Value" => "male",
        #      "Item.2.Attribute.2.Name"  => "weight",
        #      "Item.2.Attribute.2.Value" => "188",
        #      "Item.2.Attribute.3.Name"  => "age",
        #      "Item.2.Attribute.3.Value" => "42",
        #      "Item.3.ItemName"          => "diana",
        #      "Item.3.Attribute.1.Name"  => "sex",
        #      "Item.3.Attribute.1.Value" => "female",
        #      "Item.3.Attribute.2.Name"  => "weight",
        #      "Item.3.Attribute.2.Value" => "120",
        #      "Item.3.Attribute.3.Name"  => "age",
        #      "Item.3.Attribute.3.Value" => "25"}
        #
        def self.parametrize(data)
          return data unless data.is_a?(Hash)
          result = {}
          #
          data.each do |mask, values|
            current_values = Utils::arrayify(values)
            current_mask   = mask.dup.to_s
            current_mask  << ".?" unless current_mask[/\?/] if current_values.size > 1
            #
            current_values.dup.each_with_index do |value, idx|
              key  = current_mask.sub('?', (idx+1).to_s)
              item = parametrize(value)
              if item.is_a?(Hash)
                item.each{ |k, v| result["#{key}.#{k}"] = v }
              else
                result[key] = item
              end
            end
          end
          result
        end
        
      end
    end
  end
end