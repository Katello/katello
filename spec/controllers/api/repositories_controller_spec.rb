require 'spec_helper'

describe Api::RepositoriesController do
  include LoginHelperMethods

  before(:each) do
    @product = Product.new
    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  describe "create a repository" do
    it 'should call pulp and candlepin layer' do
      Product.should_receive(:find_by_cp_id).with('product_1').and_return(@product)
      @product.should_receive(:add_new_content).and_return({})
      
      post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1'
    end

    context 'there is already a repo for the product with the same name' do
      before do
        Product.stub(:find_by_cp_id => @product)
        @product.stub(:add_new_content).and_return { raise Errors::ConflictException }
      end

      it "should notify about conflict" do
        post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1'
        response.code.should == '409'
      end
    end

  end
  
  describe "get a listing of repositories" do
    it 'should call pulp glue layer' do
      Pulp::Repository.should_receive(:all).and_return({})
      get 'index'
    end 
  end
  
  describe "show a repository" do
    it 'should call pulp glue layer' do
      repo_mock = mock(Glue::Pulp::Repo)
      Glue::Pulp::Repo.should_receive(:find).with("repo_1").and_return(repo_mock)
      repo_mock.should_receive(:to_hash)
      get 'show', :id => 'repo_1'
    end
  end

  describe "repository discovery" do
    it "should call Pulp::Proxy.post" do
      Pulp::Proxy.should_receive(:post).with("/services/discovery/repo/", anything).once.and_return({})
      post 'discovery'
    end
  end

  describe "repository discovery status" do
    it "should call Pulp::Proxy.get" do
      Pulp::Proxy.should_receive(:get).with("/services/discovery/repo/1/").once.and_return({})
      post 'discovery_status', :id => 1
    end
  end

end
