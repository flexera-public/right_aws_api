require_relative '../../../../../lib/right_aws_api'

require 'rspec'

describe RightScale::CloudApi::AWS::CSHelperMethods do
  module TestModule
    include RightScale::CloudApi::AWS::CSHelperMethods
  end

  describe ".fetch_all" do
    let(:client) { double("AWS Client") }
    let(:simple_response) do
      {"Foo" => {"Bar" => {"Car" =>  [1, 2] }}}
    end
    let(:response_with_marker) do
      {"Foo" => {"Bar" => {"Marker" => "foobar123", "Car" => [10, 20, 30] }}}
    end

    before do
      allow(client).to receive(:api) do |action, params|
        params["Marker"] ? simple_response : response_with_marker
      end
    end

    it "send a request to AWS" do
      expect(client).to receive(:api).with("TestRequest", {})

      TestModule.fetch_all(client, "TestRequest",
        item: "Foo/Bar/Car",
        marker: "Foo/Bar/Marker"
      )
    end

    it "sends another request if response if truncated" do
      expect(client).to receive(:api).with("TestRequest", {}).once
      expect(client).to receive(:api).with("TestRequest", {"Marker" => "foobar123"}).once

      TestModule.fetch_all(client, "TestRequest",
        item: "Foo/Bar/Car",
        marker: "Foo/Bar/Marker"
      )
    end

    it "combines results from all responses" do
      expect(
        TestModule.fetch_all(client, "TestRequest", item: "Foo/Bar/Car", marker: "Foo/Bar/Marker").length
      ).to eq(5)
    end
  end
end

