require 'spec_helper'
require 'resources/cdn'

describe CDN::CdnVarSubstitutor do

  let(:provider_url) { "https://cdn.redhat.com" }
  let(:path_with_variables) { "/content/dist/rhel/server/5/$releasever/$basearch/os" }
  let(:connect_options) do
    {:ssl_client_cert => "456",:ssl_ca_file => "fake-ca.pem", :ssl_client_key => "123"}
  end

  subject do
    CDN::CdnVarSubstitutor.new(provider_url, connect_options)
  end

  before(:each) do
    @rest_client_mock = RestClient::Resource.new(provider_url, connect_options)
    RestClient::Resource.stub(:new).with(provider_url, connect_options).and_return(@rest_client_mock)
    @rest_client_mock.stub(:"[]").and_return do |path|
      path_mock = mock
      path_mock.stub!(:get).and_return do |headers|
        case path.count("/")
        when 7 then "i386\nx86_64"
        when 6 then "6\n61"
        else raise "unexpected count of nested paths: #{path}"
        end
      end
      path_mock
    end
  end

  it "should substitute all variables with values in listings" do
    substitutions_with_urls = subject.substitute_vars(path_with_variables)
    substitutions_with_urls[{"releasever" => "6", "basearch" => "i386"}].should == "/content/dist/rhel/server/5/6/i386/os"
    substitutions_with_urls[{"releasever" => "61", "basearch" => "i386"}].should == "/content/dist/rhel/server/5/61/i386/os"
    substitutions_with_urls[{"releasever" => "6", "basearch" => "x86_64"}].should == "/content/dist/rhel/server/5/6/x86_64/os"
    substitutions_with_urls[{"releasever" => "61", "basearch" => "x86_64"}].should == "/content/dist/rhel/server/5/61/x86_64/os"
    substitutions_with_urls.should have(4).items
  end
end
