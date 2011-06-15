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
  end
  
  describe "get a listing of repositories" do
    it 'should call pulp glue layer' do
      Pulp::Repository.should_receive(:all).and_return({})
      get 'index'
    end 
  end
  
  describe "show a repository" do
    it 'should call pulp glue layer' do
      Pulp::Repository.should_receive(:find).with('repo_1').and_return({})
      get 'show', :id => 'repo_1'
    end
  end

end
