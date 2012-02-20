require 'spec_helper'
require 'resources/cdn'

describe CDN::CdnVarSubstitutor do

  let(:provider_url) { "https://cdn.redhat.com" }
  let(:path_with_variables) { "/content/dist/rhel/server/5/$releasever/$basearch/os" }
  let(:another_path_with_variables) { "/content/dist/rhel/server/6/$releasever/$basearch/os" }
  let(:connect_options) do
    {:ssl_client_cert => "456",:ssl_ca_file => "fake-ca.pem", :ssl_client_key => "123"}
  end

  subject do
    CDN::CdnVarSubstitutor.new(provider_url, connect_options)
  end

  it "should substitute all variables with values in listings" do
    stub_successful_cdn_requests(["6","61"],["i386", "x86_64"])
    substitutions_with_urls = subject.substitute_vars(path_with_variables)
    substitutions_with_urls[{"releasever" => "6", "basearch" => "i386"}].should == "/content/dist/rhel/server/5/6/i386/os"
    substitutions_with_urls[{"releasever" => "61", "basearch" => "i386"}].should == "/content/dist/rhel/server/5/61/i386/os"
    substitutions_with_urls[{"releasever" => "6", "basearch" => "x86_64"}].should == "/content/dist/rhel/server/5/6/x86_64/os"
    substitutions_with_urls[{"releasever" => "61", "basearch" => "x86_64"}].should == "/content/dist/rhel/server/5/61/x86_64/os"
    substitutions_with_urls.should have(4).items
  end

  it "should be able to use proxy" do
    AppConfig.cdn_proxy = OpenStruct.new(:host => "localhost", :port => 3128, :user => "test", :password => "pwd")

    Net::HTTP.stub("Proxy" => Net::HTTP)
    Net::HTTP.should_receive("Proxy").with("localhost", 3128, "test", "pwd")

    subject
  end

  it "should be able to use url as proxy host" do
    AppConfig.cdn_proxy = OpenStruct.new(:host => "http://localhost", :port => 3128, :user => "test", :password => "pwd")

    Net::HTTP.stub("Proxy" => Net::HTTP)
    Net::HTTP.should_receive("Proxy").with("localhost", 3128, "test", "pwd")

    subject
  end

  describe "batch substitutions calculation" do
    it "should calculate all substitutions at once" do
      subject.should_receive(:substitute_vars).with(path_with_variables).and_return([])
      subject.should_receive(:substitute_vars).with(another_path_with_variables).and_return([])
      subject.precalculate([path_with_variables, another_path_with_variables])
    end

    it "should use the precalculated results for substitutions" do
      stub_successful_cdn_requests(["6","61"],["i386", "x86_64"])
      subject.precalculate([path_with_variables])
      subject.should_not_receive :for_each_substitute_of_next_var # doesn't calculate results
      substitutions_with_urls = subject.substitute_vars(path_with_variables)
      substitutions_with_urls.should have(4).items
    end

    it "should describe why it failed when some listing unavailable" do
      stub_not_found_cdn_request
      expect { subject.precalculate([path_with_variables]) }.to raise_error Errors::NotFound, /\/content\/dist\/rhel\/server\/5\/listing not found/
    end
  end


  it "should handle error codes from CDN" do
    stub_forbidden_cdn_requests
    lambda { subject.substitute_vars(path_with_variables) }.should raise_error RestClient::Forbidden
  end

  it "it should be able to cache the resolved paths" do
    stub_successful_cdn_requests(["6","61"],["i386", "x86_64"])

    @net_mock.should_receive(:start).exactly(3).times
    CDN::CdnVarSubstitutor.with_cache do
      CDN::CdnVarSubstitutor.new(provider_url, connect_options).substitute_vars(path_with_variables)
      CDN::CdnVarSubstitutor.new(provider_url, connect_options).substitute_vars(path_with_variables)
    end
  end

  it "it should cache the resolved paths only in with_cache block" do
    stub_successful_cdn_requests(["6","61"],["i386", "x86_64"])

    @net_mock.should_receive(:start).exactly(6).times
    CDN::CdnVarSubstitutor.with_cache do
      CDN::CdnVarSubstitutor.new(provider_url, connect_options).substitute_vars(path_with_variables)
    end
    CDN::CdnVarSubstitutor.new(provider_url, connect_options).substitute_vars(path_with_variables)
  end


  # all requests for listing releasevers and basearchs reeturn the values in
  # arguments.
  def stub_successful_cdn_requests(releasevers, basearchs)
    stub_cdn_requests do |req,headers|
      body = case req.path.count("/")
             when 6 then releasevers.join("\n")
             when 7 then basearchs.join("\n")
             else raise "unexpected count of nested paths: #{req.path}"
             end
      mock(:code => 200, :body => body)
    end
  end

  def stub_forbidden_cdn_requests
    stub_cdn_requests { |req,headers| mock(:code => 403, :body => nil) }
  end

  def stub_not_found_cdn_request
    stub_cdn_requests { |req,headers| mock(:code => 404, :body => nil) }
  end

  def stub_cdn_requests(&block)
    uri = URI.parse(provider_url)
    @net_mock = Net::HTTP.new(uri.host, uri.port)
    Net::HTTP.stub(:new).with(uri.host, uri.port).and_return(@net_mock)
    request_mock = mock
    request_mock.stub!(:request).and_return(&block)
    @net_mock.stub(:start).and_yield(request_mock)
  end

end

