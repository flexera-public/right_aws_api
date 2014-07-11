require 'right_aws_api'

require 'rspec'

describe RightScale::CloudApi::AWS::S3::Link::RequestSigner do


  context '#compute_params!' do
    before :each do
      @access_key = 'access-key'
    end

    context 'Expires' do
      it 'defaults to something in the future' do
        result = subject.compute_params!({}, @access_key)
        expect(result['Expires']).to be_an(Integer)
      end

      it 'sets the passed value' do
        expectation = 123
        result      = subject.compute_params!({ 'Expires' => expectation }, @access_key)
        expect(result['Expires']).to eq(expectation)
      end
    end


    context 'AWSAccessKeyId' do
      it 'sets the passed value' do
        result = subject.compute_params!({}, @access_key)
        expect(result['AWSAccessKeyId']).to eq(@access_key)
      end
    end

  end


  context '#compute_signature' do
    before :each do
      @secret_key = 'secret-key'
      @verb       = :get
      @bucket     = 'foo-bar'
      @object     = 'foo%2Fbar%2F%D0%B1%D0%B0%D0%BD%D0%B0%D0%BD%D0%B0.jpg'
      @params     = { 'Foo' => 1, 'Bar' => 2, 'Expires' => 1000000 }
      @expectation = "EShMsLs2Bqak5YuIqOTJq15qcJE="
      @result      = subject.compute_signature(@secret_key, @verb, @bucket, @object, @params)
    end

    it 'properly calculates the signature' do
      expect(@result).to eq(@expectation)
    end
  end

end
