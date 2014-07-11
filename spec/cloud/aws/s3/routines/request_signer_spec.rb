require 'right_aws_api'

require 'rspec'

describe RightScale::CloudApi::AWS::S3::RequestSigner do
  context '#get_subresources' do
    before :each do
      @sub_resources = {
        'acl'                       => 0,
        'policy'                    => 0,
        'versions'                  => 0,
        'website'                   => 0,
        'response-content-type'     => 0,
        'response-content-language' => 0,
        'response-foo-bar'          => 0,
      }
      trash = {
        'foo' => 0,
        'bar' => 0,
      }
      params = @sub_resources.merge(trash)
      @result = subject.get_subresources(params)
    end

    it "extracts SUB_RESOURCES and response- params" do
      expect(@result).to eq(@sub_resources)
    end
  end


  context '#compute_canonicalized_bucket' do
    context 'DNS bucket' do
      it 'adds a trailing slash' do
        expect(subject.compute_canonicalized_bucket('foo-bar')).to eq('foo-bar/')
      end
    end

    context 'non DNS bucket' do
      it 'does nothing' do
        expect(subject.compute_canonicalized_bucket('foo_bar')).to eq('foo_bar')
      end
    end
  end


  context '#compute_canonicalized_path' do
    context 'with no sub-resources' do
      before :each do
        bucket        = 'foo-bar_bucket'
        relative_path = 'a/b/c/d.jpg'
        params        = { 'Foo' => 1, 'acl' => '2', 'response-content-type' => 'jpg' }
        @result       = subject.compute_canonicalized_path(bucket, relative_path, params)
        @expectation  = '/foo-bar_bucket/a/b/c/d.jpg?acl=2&response-content-type=jpg'
      end

      it 'works' do
        expect(@result).to eq(@expectation)
      end
    end
  end



  context '#compute_bucket_name_and_object_path' do
    before :each do
      @original_path = 'my-test-bucket/foo/bar/банана.jpg'
      @bucket        = 'my-test-bucket'
      @relative_path = 'foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg'
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
      it 'defaults content-type to application/octet-stream' do
        result      = subject.compute_headers!(@headers, @body, @host)
        expectation = ['application/octet-stream']
        expect(result['content-type']).to eq(expectation)
      end
    end


    context 'date' do
      it 'sets date' do
        result = subject.compute_headers!(@headers, @body, @host)
        expect(result['date']).to       be_an(Array)
        expect(result['date'].first).to be_a(String)
      end
    end


    context 'content-md5' do
      context 'body is blank' do
        it 'does not set the header' do
          result = subject.compute_headers!(@headers, @body, @host)
          expect(result['content-md5']).to eq([])
        end
      end


      context 'body is not blank' do
        it 'does not set the header' do
          result = subject.compute_headers!(@headers, 'woo-hoo', @host)
          expect(result['content-md5']).to eq(['Ezs4dVuMkr7EgUDB41SEMg=='])
        end
      end
    end


    context 'host' do
      it 'sets the host' do
        result = subject.compute_headers!(@headers, @body, @host)
        expect(result['host']).to eq([@host])
      end
    end
  end


  context '#compute_signature' do
    before :each do
      @secret_key = 'secret-key'
      @verb       = :get
      @bucket     = 'foo-bar'
      @object     = 'foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg'
      @params     = { 'Foo' => 1, 'Bar' => 2}
      @headers    = RightScale::CloudApi::HTTPHeaders.new(
        'x-amz-foo-bar' => '1',
        'x-amx-foo-boo' => '2',
        'date'          => 'Fri, 11 Jul 2014 21:25:46 GMT',
        'other-header'  => 'moo'
      )
      @expectation = "Z7hSptZVg7WytxFfM7K73henBpA="
      @result      = subject.compute_signature(@access_key, @secret_key, @verb, @bucket, @object, @params, @headers)
    end

    it 'properly calculates the signature' do
      expect(@result).to eq(@expectation)
    end
  end


  context '#compute_path' do
    before :each do
      @path   = 'foo-bar'
      @object = 'foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg'
      @params = { 'Foo' => 1, 'Bar' => 2}
    end

    it 'works for DNS bucket' do
      expect(subject.compute_path('foo-bar', @object, @params)).to eq('/foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg?Bar=2&Foo=1')
    end

    it 'works for non DNS bucket' do
      expect(subject.compute_path('foo_bar', @object, @params)).to eq('/foo_bar/foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg?Bar=2&Foo=1')
    end
  end
end
