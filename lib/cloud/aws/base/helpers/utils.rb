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
    # Helper methods namespace
    module Utils
      # AWS helpers namespace
      module AWS

        @@digest1   = OpenSSL::Digest.new("sha1")
        @@digest256 = nil
        if OpenSSL::OPENSSL_VERSION_NUMBER > 0x00908000
          @@digest256 = OpenSSL::Digest.new("sha256") rescue nil # Some installations may not support sha256
        end


        # Generates a signature for the given string, secret access key and digest
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


        # Returns ISO-8601 representation for the given time
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


        # Escapes a string accordingly to Amazon rules
        # @see http://docs.aws.amazon.com/general/latest/gr/signature-version-2.html
        #
        # @param [String] string
        # @return [String]
        #
        # @example
        #   RightScale::CloudApi::Utils::AWS.amz_escape('something >= 13') #=>
        #     'something%20%3E%3D%2013'
        #
        def self.amz_escape(string)
          string = string.to_s
          # Use UTF-8 if current ruby supports it (1.9+)
          string = string.encode("UTF-8") if string.respond_to?(:encode)
          # CGI::escape is too clever:
          #  - it escapes '~' when Amazon wants it to be un-escaped
          #  - it escapes ' ' as '+' but Amazon loves it as '%20'
          CGI.escape(string).gsub('%7E','~').gsub('+','%20')
        end


        # Signature Version 2
        #
        # EC2, SQS and SDB requests must be signed by this guy
        #
        # @param [String]        aws_secret_access_key
        # @param [Hash]          params
        # @param [String,Symbol] verb  'get' | 'post'
        # @param [String]        host
        # @param [String]        urn
        #
        # @return [String]
        #
        # @example
        #   params = {'InstanceId' => 'i-00000000'}
        #   sign_v2_signature('secret', params, :get, 'ec2.amazonaws.com', '/') #=>
        #     "InstanceId=i-00000000&SignatureMethod=HmacSHA256&SignatureVersion=2&
        #      Timestamp=2014-03-12T21%3A52%3A21.000Z&Signature=gR2x3oWmNbh4bdZksPS
        #      sg3t7U0zbTcnFOfizWF3Zujw%3D"
        #
        # @see http://docs.aws.amazon.com/general/latest/gr/signature-version-2.html
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


        # Returns +true+ if the provided bucket name is  a DNS compliant bucket name
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


        # Signs and Authenticates REST Requests
        #
        # @param [String]        aws_secret_access_key
        # @param [String,Symbol] verb  'get' | 'post'
        # @param [String]        canonicalized_resource
        # @param [Hash]          _headers
        #
        # @return [String]
        #
        # @example
        #  sign_s3_signature('secret', :get, 'xxx/yyy/zzz/object', {'header'=>'value'}) #=>
        #    "i85igH0sftHD/cGZcLiBKcYEuks="
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


        def self.sign_v4_get_service_and_region(host)
          result =
            case
            when host[                  /^iam\.amazonaws\.com$/i ] then ['iam', 'us-east-1']
            when host[              /^iam\.amazonaws\.com\.cn$/i ] then ['iam', 'cn-north-1']
            when host[              /^route53\.amazonaws\.com$/i ] then ['route53', 'us-east-1']
            when host[            /^(.*\.)?s3\.amazonaws\.com$/i ] then ['s3',  'us-east-1']
            when host[ /^(.*\.)?s3-external-1\.amazonaws\.com$/i ] then ['s3',  'us-east-1']
            when host[    /s3-website(-|\.)([^.]+)\.amazonaws\.com(\.cn)?$/i ] then ['s3', $2]
            when host[     /^(.*\.)?s3-([^.]+).amazonaws\.com(\.cn)?$/i ] then ['s3', $2]
            when host[   /^(.*\.)?s3\.([^.]+)\.amazonaws\.com(\.cn)?$/i ] then ['s3', $2]
            else host[     /^([^.]+)\.([^.]+)\.amazonaws\.com(\.cn)?$/i ]   && [$1,   $2]
            end
          fail(ArgumentError, "Cannot extract service name from %s host" % host.inspect) if !result || result[0].to_s.empty?
          fail(ArgumentError, "Cannot extract region name from %s host"  % host.inspect) if result[1].to_s.empty?
          result
        end


        # Signs and Authenticates REST Requests
        #
        # @param [String]        aws_secret_access_key
        # @param [String]        aws_access_key
        # @param [String]        host
        # @param [Hash]          request
        #
        # @return [String]
        #
        # @see http://docs.aws.amazon.com/general/latest/gr/signature-version-4.html
        #
        def self.sign_v4_signature(aws_access_key, aws_secret_access_key, host, request, method=:headers)
          now             = Time.now.utc
          current_date    = now.strftime("%Y%m%d")
          current_time    = now.strftime("%Y%m%dT%H%M%SZ")
          host            = host.downcase
          service, region = sign_v4_get_service_and_region(host)
          creds_scope     = "%s/%s/%s/aws4_request" % [current_date, region, service]
          algorithm       = "AWS4-HMAC-SHA256"

          # Verb
          canonical_verb = sign_v4_get_canonical_verb(request[:verb])

          # Path
          request[:path] ||= '/'
          canonical_path   = sign_v4_get_canonical_path(request[:path])

          # Headers (Auth)
          request[:headers].delete('Authorization')
          if method == :headers
            canonical_payload = sign_v4_headers(request, host, current_time)
          end
          # Headers (Standard)
          request[:headers]['Host'] = host
          _headers = {}
          request[:headers].each do |key, value|
            _headers[key.to_s.downcase] = value.is_a?(Array) ? value.join(',') : value
          end
          canonical_headers = sign_v4_get_canonical_headers(_headers)
          signed_headers    = sign_v4_get_signed_headers(_headers)

          # Params (Auth)
          if method != :headers
            canonical_payload = sign_v4_query_params(
              request,
              algorithm,
              current_time,
              signed_headers,
              aws_access_key,
              creds_scope
            )
          end
          # Params (Standard)
          canonical_query_string = Utils::params_to_urn(request[:params]){ |value| amz_escape(value) }

          # Canonical String
          canonical_string = sign_v4_get_canonical_string(
            canonical_verb,
            canonical_path,
            canonical_query_string,
            canonical_headers,
            signed_headers,
            canonical_payload
          )

          # StringToSign
          string_to_sign = sign_v4_get_string_to_sign(algorithm, current_time, creds_scope, canonical_string)

          # Signature
          signature = sign_v4_get_signature_key(aws_secret_access_key, string_to_sign, current_date, region, service)

          request[:path] += "?%s" % canonical_query_string unless canonical_query_string.empty?

          if method == :headers
            # Authorization Header
            authorization_header = "%s Credential=%s/%s, SignedHeaders=%s, Signature=%s" %
                                   [algorithm, aws_access_key, creds_scope, signed_headers, signature]
            request[:headers]['Authorization'] = authorization_header
          else
            request[:path] += "&X-Amz-Signature=%s" % signature
          end
        end


        def self.sign_v4_get_canonical_verb(verb)
          verb.to_s.upcase
        end


        def self.sign_v4_get_canonical_path(path)
          path
        end


        def self.sign_v4_query_params(request, algorithm, current_time, signed_headers, aws_access_key, creds_scope)
          expires_at = request[:params]['X-Amz-Expires'] || 3600
          expires_at = expires_at.to_i if expires_at.is_a?(Time)

          request[:params]['X-Amz-Date']          = current_time
          request[:params]['X-Amz-Expires']       = expires_at
          request[:params]['X-Amz-Algorithm']     = algorithm
          request[:params]['X-Amz-SignedHeaders'] = signed_headers
          request[:params]['X-Amz-Credential']    = "%s/%s" % [aws_access_key, creds_scope]

          'UNSIGNED-PAYLOAD'
        end


        def self.sign_v4_get_canonical_headers(headers)
          headers.sort.map{ |key, value| "#{key}:#{value}" }.join("\n")
        end


        def self.sign_v4_get_signed_headers(headers)
          headers.keys.sort.join(';')
        end


        def self.sign_v4_headers(request, host, current_time)
          expires_at = request[:headers]['X-Amz-Expires'].first || 3600
          expires_at = expires_at.to_i if expires_at.is_a?(Time)

          if request[:body].is_a?(IO)
            canonical_payload = ''
            request[:headers].set_if_blank('X-Amz-Content-Sha256', 'UNSIGNED-PAYLOAD')
          else
            request[:body]    = request[:body].to_s
            canonical_payload = hex_encode(Digest::SHA256.digest(request[:body]))
            content_type      = 'application/x-www-form-urlencoded; charset=utf-8'
            content_md5       = Base64::encode64(Digest::MD5::digest(request[:body])).strip
            request[:headers].set_if_blank('Content-Length',       request[:body].bytesize)
            request[:headers].set_if_blank('Content-Type',         content_type)
            request[:headers].set_if_blank('Content-Md5',          content_md5)
            request[:headers].set_if_blank('X-Amz-Content-Sha256', canonical_payload)
          end
          request[:headers]['X-Amz-Date']    = current_time
          request[:headers]['X-Amz-Expires'] = expires_at

          canonical_payload
        end


        # Signature V4: Returns Canonical String
        #
        # @return [String]
        #
        def self.sign_v4_get_canonical_string(verb, path, query_string, headers, signed_headers, payload)
          verb           + "\n"   +
          path           + "\n"   +
          query_string   + "\n"   +
          headers        + "\n\n" +
          signed_headers + "\n"   +
          payload
        end


        # Signature V4: A string to sign value
        #
        # @return [String]
        #
        def self.sign_v4_get_string_to_sign(algorithm, current_time, creds_scope, canonical_string)
          algorithm    + "\n" +
          current_time + "\n" +
          creds_scope  + "\n" +
          hex_encode(Digest::SHA256.digest(canonical_string)).downcase
        end


        #Helpers from AWS documentation http://docs.aws.amazon.com/general/latest/gr/signature-v4-examples.html
        def self.sign_v4_get_signature_key(key, string_to_sign, date, region, service, digest = @@digest256)
          k_date    = OpenSSL::HMAC.digest(digest, "AWS4" + key, date)
          k_region  = OpenSSL::HMAC.digest(digest, k_date,       region)
          k_service = OpenSSL::HMAC.digest(digest, k_region,     service)
          k_signing = OpenSSL::HMAC.digest(digest, k_service,    "aws4_request")
          hex_encode  OpenSSL::HMAC.digest(digest, k_signing,    string_to_sign)
        end


        def self.hex_encode(bindata)
          result=""
          data=bindata.unpack("C*")
          data.each {|b| result+= "%02x" % b}
          result
        end


        # Parametrizes data to the format that Amazon EC2 (and compatible APIs) loves
        #
        # @param [Hash] data
        #
        # @return [Hash]
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
