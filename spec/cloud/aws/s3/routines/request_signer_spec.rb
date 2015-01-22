require 'right_aws_api'

require 'rspec'

describe RightScale::CloudApi::AWS::S3::RequestSigner do

  context '#compute_bucket_name_and_object_path' do
    before :each do
      @original_path = 'my-test-bucket/foo/bar/банана.jpg'
      @bucket        = 'my-test-bucket'
      @relative_path = 'foo/bar/%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg'
    end

    context 'when this is a first API call attempt' do
      before :each do
        @r_bucket, @r_path = subject.compute_bucket_name_and_object_path(nil, @original_path)
      end

      it "extracts the bucket and escapes the path" do
        expect(@r_bucket).to eq(@bucket)
        expect(@r_path).to   eq(@relative_path)
      end
    end


    context 'when there is a redirect and the bucket is already extracted' do
      before :each do
        @r_bucket, @r_path = subject.compute_bucket_name_and_object_path(@bucket, @relative_path)
      end

      it "does nothing" do
        expect(@r_bucket).to eq(@bucket)
        expect(@r_path).to   eq(@relative_path)
      end
    end
  end


  context '#compute_host' do
    before :each do
      allow(subject).to receive(:no_dns_buckets?).and_return(false)
    end

    context 'DNS bucket' do
      before :each do
        bucket  = 'foo-bar-bucket'
        uri     = URI.parse('https://a.b.com')
        @result = subject.compute_host(bucket, uri)
        @expectation = 'https://foo-bar-bucket.a.b.com'
      end

      it 'prepends the host name with the bucket name' do
        expect(@result.to_s).to eq(@expectation)
      end
    end


    context 'non DNS bucket' do
      before :each do
        bucket  = 'foo-bar_bucket'
        uri     = URI.parse('https://a.b.com')
        @result = subject.compute_host(bucket, uri)
        @expectation = 'https://a.b.com'
      end

      it 'has no effect on the host name' do
        expect(@result.to_s).to eq(@expectation)
      end
    end
  end


  context '#compute_body' do
    it 'has no effect for non Hash body' do
      expect(subject.compute_body(nil, 'application/json')).to eq(nil)
      expect(subject.compute_body(1,   'application/json')).to eq(1)
      expect(subject.compute_body([1], 'application/json')).to eq([1])
    end

    it 'converts Hashes to the required content type' do
      expect(subject.compute_body({1 => 2}, 'application/json')).to eq("{\"1\":2}")
      expect(subject.compute_body({1 => 2}, 'application/xml')).to  eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<1>2</1>")
    end
  end


  context '#compute_headers!' do
    before :each do
      @headers = RightScale::CloudApi::HTTPHeaders.new
      @body    = nil
      @host    = 'foo_bar.host.com'
    end

    context 'content-type' do
      it 'defaults content-type to binary/octet-stream' do
        result      = subject.compute_headers!(@headers, @body, @host)
        expectation = ['binary/octet-stream']
        expect(result['content-type']).to eq(expectation)
      end
    end
  end


  context '#compute_path' do
    before :each do
      @path   = 'foo-bar'
      @object = 'foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg'
      allow(subject).to receive(:no_dns_buckets?).and_return(false)
    end

    it 'works for DNS bucket' do
      expect(subject.compute_path('foo-bar', @object)).to eq('/foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg')
    end

    it 'works for non DNS bucket' do
      expect(subject.compute_path('foo_bar', @object)).to eq('/foo_bar/foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg')
    end
  end
end
