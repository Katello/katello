require 'spec_helper'

describe 'Candlepin::Consumer' do
  
  before(:each) do
    url = "http://localhost:8080/candlepin"    
    Candlepin::Consumer.prefix = URI.parse(url).path
    Candlepin::Consumer.site = url.gsub(Candlepin::Consumer.prefix, "")    
    
    User.current = User.new(:username => 'admin', :password => 'admin')
    
    @test_owner = Candlepin::Owner.create('test_owner' + random_string, 'test owner')
    @consumer_1 = Candlepin::Consumer.create @test_owner[:key], 'test_consumer_' + random_string, 'system', {}
  end
  
  it "should return a consumer for specified uuid" do
    consumer = Candlepin::Consumer.get(@consumer_1[:uuid])
    
    consumer[:uuid].should == @consumer_1[:uuid]
    consumer[:name].should == @consumer_1[:name]    
  end
  
  it "should raise RestClient::ResourceNotFound for non-existant uuid" do
    lambda {consumer = Candlepin::Consumer.get('12345')}.should raise_exception(RestClient::ResourceNotFound)
  end
  
  def random_string
    rand(100000).to_s
  end

end
