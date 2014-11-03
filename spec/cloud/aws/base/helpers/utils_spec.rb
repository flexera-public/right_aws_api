require_relative '../../../../../lib/right_aws_api'

require 'rspec'

describe RightScale::CloudApi::Utils::AWS do
  subject do
    RightScale::CloudApi::Utils::AWS
  end

  context "signature v4" do

    context "sign_v4_get_service_and_region" do
      context "weird unknown host" do
        it "fails" do
          expect{
            subject.sign_v4_get_service_and_region('foo.bar.com')
          }.to raise_error(ArgumentError)
        end
      end

      context "host with no service" do
        it "fails" do
          expect{
            subject.sign_v4_get_service_and_region('foo.amazonaws.com')
          }.to raise_error(ArgumentError,/service/)
        end
      end

      context "S3" do
        it "works" do
          expect(
            subject.sign_v4_get_service_and_region('s3.amazonaws.com')
          ).to eq ['s3', 'us-east-1']

          expect(
            subject.sign_v4_get_service_and_region('xxx.s3.amazonaws.com')
          ).to eq ['s3', 'us-east-1']

          expect(
            subject.sign_v4_get_service_and_region('s3-external-1.amazonaws.com')
          ).to eq ['s3', 'us-east-1']

          expect(
            subject.sign_v4_get_service_and_region('s3-region-1.amazonaws.com')
          ).to eq ['s3', 'region-1']

          expect(
            subject.sign_v4_get_service_and_region('xxx.s3-region-1.amazonaws.com')
          ).to eq ['s3', 'region-1']

          expect(
            subject.sign_v4_get_service_and_region('s3.region-1.amazonaws.com')
          ).to eq ['s3', 'region-1']

          expect(
            subject.sign_v4_get_service_and_region('xxx.s3.region-1.amazonaws.com')
          ).to eq ['s3', 'region-1']
        end
      end


      context "any other service with standard endpoint" do
        it "works" do
          expect(
            subject.sign_v4_get_service_and_region('ec2.region-1.amazonaws.com')
          ).to eq ['ec2', 'region-1']
        end
      end
    end


    context "sign_v4_get_canonical_verb" do
      it "uppercases the given verb" do
        expect( subject.sign_v4_get_canonical_verb(:delete) ).to eq 'DELETE'
      end
    end


    context "sign_v4_get_canonical_path" do
      it "does nothing to the given path" do
        expect( subject.sign_v4_get_canonical_path('foo/bar') ).to eq 'foo/bar'
      end
    end


    context "sign_v4_get_canonical_headers" do
      it "works" do
        headers = {
          'foo' => 'x',
          'bar' => 'y,z'
        }
        expect(
          subject.sign_v4_get_canonical_headers(headers)
        ).to eq "bar:y,z\nfoo:x"
      end
    end


    context "sign_v4_get_signed_headers" do
      it "works" do
        headers = {
          'foo' => 'x',
          'bar' => 'y,z'
        }
        expect(
          subject.sign_v4_get_signed_headers(headers)
        ).to eq "bar;foo"
      end
    end


    context "sign_v4_headers" do
      it "builds credential params" do
        request = {
          :headers => RightScale::CloudApi::HTTPHeaders.new,
          :params  => { 'A' => 'B' },
          :body    => "banana"
        }
        expect(
          subject.sign_v4_headers(
            request,
            "ec2.region-1.amazonaws.com",
            "20141103T150750Z"
          )
        ).to eq "b493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e"

        expect(request).to eq(
          {
            :body    => "banana",
            :params  => { 'A' => 'B' },
            :headers => {
              "content-length"       => [6],
              "content-type"         => ["application/x-www-form-urlencoded; charset=utf-8"],
              "content-md5"          => ["crMCvyl6Iop1cwEj7+98QQ=="],
              "x-amz-content-sha256" => ["b493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e"],
              "x-amz-date"           => ["20141103T150750Z"],
              "x-amz-expires"        => [3600]
            }
          }
        )
      end
    end


    context "sign_v4_query_params" do
      it "builds credential params" do
        request = { :params => {} }
        expect(
          subject.sign_v4_query_params(
            request,
            "AWS4-HMAC-SHA256",
            "20141103T150750Z",
            "host;content-type",
            "aws_access_key",
            "20141103/region-1/ec2/aws4_request"
          )
        ).to eq "UNSIGNED-PAYLOAD"

        expect(request).to eq(
          {
            :params => {
              "X-Amz-Date"          => "20141103T150750Z",
              "X-Amz-Expires"       => 3600,
              "X-Amz-Algorithm"     => "AWS4-HMAC-SHA256",
              "X-Amz-SignedHeaders" => "host;content-type",
              "X-Amz-Credential"    => "aws_access_key/20141103/region-1/ec2/aws4_request"
            }
          }
        )
      end
    end


    context "sign_v4_get_canonical_string" do
      it "joins things properly" do
        expect(
          subject.sign_v4_get_canonical_string(
            'verb',
            'path',
            'query_string',
            'headers',
            'signed_headers',
            'payload'
          )
        ).to eq "verb\npath\nquery_string\nheaders\n\nsigned_headers\npayload"
      end
    end


    context "sign_v4_get_string_to_sign" do
      it "joins things properly" do
        expect(
          subject.sign_v4_get_string_to_sign('algorithm', 'current_time', 'creds_scope', 'canonical_string')
        ).to eq "algorithm\ncurrent_time\ncreds_scope\ne32453154e605024921ee9c5eb4ee7eba458cbd2b387c9ac74e729f9fd7cb81b"
      end
    end


    context "sign_v4_get_signature_key" do
      it "works" do
        expect(
          subject.sign_v4_get_signature_key('key', 'string_to_sign', 'date', 'region', 'service')
        ).to eq "0eb6bf1678c804d70bdda801326b3b70080ff19f2cb381e28231b2dcdd445b7c"
      end
    end


    context "hex_encode" do
      it "works" do
        expect(
          subject.hex_encode('HelloWorld!')
        ).to eq "48656c6c6f576f726c6421"
      end
    end
  end
end
