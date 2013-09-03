require 'spec_helper'

describe 'Resources::Candlepin::Consumer' do

  before(:each) do
    url = "http://localhost:8080/candlepin"
    Resources::Candlepin::Consumer.prefix = URI.parse(url).path
    Resources::Candlepin::Consumer.site = url.gsub(Resources::Candlepin::Consumer.prefix, "")

    User.current = User.new(:username => 'admin', :password => 'admin')

    @test_owner = Resources::Candlepin::Owner.create('test_owner' + random_string, 'test owner')
    @consumer_1 = Resources::Candlepin::Consumer.create @test_owner[:key], 'test_consumer_' + random_string, 'system', {}
  end

  it "should return a consumer for specified uuid" do
    consumer = Resources::Candlepin::Consumer.get(@consumer_1[:uuid])

    consumer[:uuid].should == @consumer_1[:uuid]
    consumer[:name].should == @consumer_1[:name]
  end

  it "should raise RestClient::ResourceNotFound for non-existant uuid" do
    lambda { Resources::Candlepin::Consumer.get('12345') }.should raise_exception(RestClient::ResourceNotFound)
  end

  def random_string
    rand(100_000).to_s
  end

end
