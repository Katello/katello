#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'

describe FiltersController, :katello => true do

  include LoginHelperMethods
  include LocaleHelperMethods
  include ProductHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include RepositoriesHelper
  before(:each) do

      set_default_locale
      login_user
      disable_filter_orchestration
      disable_product_orchestration
      disable_repo_orchestration
      controller.stub(:search_validate).and_return(true)

  end

  describe "Controller tests" do
    before(:each) do
      @organization = new_test_org
      @filter = Filter.create!(:name => 'filter', :organization => @organization)
      @env = @organization.library
      @product = new_test_product(@organization, @env)
      ep_library = EnvironmentProduct.find_or_create(@organization.library, @product)
      @repo = Repository.create!(:environment_product => ep_library,
                                 :name=> "repo",
                                 :label => "repo_label",
                                 :relative_path => "#{@organization.name}/Library/prod/repo",
                                 :pulp_id=> "1",
                                 :enabled => true,
                                 :feed => 'https://localhost')

    end

    describe "GET index" do
      it "requests filters using search criteria" do
        get :index
        response.should be_success
      end
    end

    describe "GET items" do
      it "requests filters using search criteria" do
        controller.should_receive(:render_panel_direct)
        controller.stub(:render)
        get :items
        response.should be_success
        
      end
    end

    describe "create filter" do
      it "posts to create a filter should be sucessful" do
        controller.should notify.success
        post :create, :filter => {:name=>"testfilter"}
        response.should be_success
        Filter.where(:name=>"testfilter").first.name.should == "testfilter"
      end

      it "posts to create a filter should not be sucessful if no name" do
        controller.should notify.exception
        post :create, :filter => {}
        response.should_not be_success
      end

      it_should_behave_like "bad request"  do
        let(:req) do
          post :create, :filter => {:name=>"testfilter", :bad_foo =>"lame"}
        end
      end
    end

    describe 'show a filter' do
      it 'should return succesfully for a valid filter' do
        get :show, :id=>@filter.id
        response.should be_success
      end

      it 'should return succesfully for a valid filter' do
        get :show, :id=>-1
        response.should_not  be_success
      end
    end


    describe "edit a filter" do
      it "should recieve a valid filter for edit" do
        get :edit, :id=>@filter.id
        response.should be_success
      end

      it "should not recieve a valid filter for edit a non-existant id" do
        controller.should notify.error
        get :edit, :id=>-1
        response.should_not be_success
      end
    end

    describe "get products" do
      it "should recieve a valid filter for edit" do
        get :products, :id=>@filter.id
        response.should be_success
      end

      it "should not recieve a valid filter for edit a non-existant id" do
        controller.should notify.error
        get :products, :id=>-1
        response.should_not be_success
      end
    end

    describe "get packages" do
      it "should recieve a valid filter for edit" do
        get :packages, :id=>@filter.id
        response.should be_success
      end

      it "should not recieve a valid filter for edit a non-existant id" do
        controller.should notify.error
        get :packages, :id=>-1
        response.should_not be_success
      end
    end


    describe "update a filter" do
      it "should allow updating of description" do
        Filter.stub(:find).and_return(@filter)
        @filter.should_receive(:description=)
        @filter.stub(:save_filter_orchestration)

        post :update, :id=> @filter, :filter=>{:description=>"TestDescription"}
        response.should be_success
      end

      it "should not allow updating of description of bad id" do
        post :update, :id=> -1, :filter=>{:description=>"TestDescription"}
        response.should_not be_success
      end

      it_should_behave_like "bad request"  do
        let(:req) do
          post :update, :id=> @filter, :filter=>{:description=>"TestDescription", :bad_foo =>"lame"}
        end
      end
    end

    describe "fetch new filter" do
      it "should recieve a valid filter for edit" do
        get :new
        response.should be_success
      end
    end

    describe "delete a filter" do
      it "should be successful with a valid filter" do
        Filter.stub(:find).and_return @filter
        controller.should notify.success
        @filter.should_receive(:destroy)
        controller.stub(:render) #can't find common
        delete :destroy, :id=>@filter.id
        response.should be_success
      end
      
      it "should not be successful with a valid filter" do
        controller.should notify.error
        delete :destroy, :id=>-12343
        response.should_not be_success
      end

    end

    describe "Set products" do
      it "should allow for updating of products for a valid product" do
        controller.should notify.success
        post :update_products, :id=>@filter.id, :products=>[@product.id]
        response.should be_success
        assert !Filter.find(@filter.id).products.empty?
      end

      it "should allow for updating of products for a empty products" do
        @filter.products << @product
        @filter.save!
        controller.should notify.success
        post :update_products, :id=>@filter.id, :products=>[]
        response.should be_success
        assert Filter.find(@filter.id).products.empty?
      end

      it "should not allow for updating of products for an invalid product" do
        post :update_products, :id=>@filter.id, :products=>[-1]
        response.should be_success  #invalid products are ignored
        assert Filter.find(@filter.id).products.empty?
      end

      it "should not allow for updating of products for an invalid filter" do
        controller.should notify.error
        post :update_products, :id=>"-1", :products=>[@product.id]
        response.should_not be_success
      end
      
    end


    describe "Set Repos" do
      before do
        #Repository.stub_chain([:editable_in_library, :where]).and_return([@repo])
        Repository.stub(:find).and_return(@repo)
      end
      it "should allow for updating of repos for a valid repo" do
        @repo.should_receive(:add_filters_orchestration).and_return({})
        @repo.should_not_receive(:remove_filters_orchestration)
        controller.should notify.success
        post :update_products, :id=>@filter.id, :repos=>{@repo.product.id => @repo.id}
        response.should be_success
        assert !Filter.find(@filter.id).repositories.empty?
      end

      it "should allow for updating of repos for a empty repos" do
        @filter.repositories << @repo
        @filter.save!
        @repo.should_receive(:remove_filters_orchestration).and_return({})
        controller.should notify.success
        post :update_products, :id=>@filter.id, :repos=>[]
        response.should be_success
        assert Filter.find(@filter.id).repositories.empty?
      end

      it "should not allow for updating of repos for an invalid product" do
        @repo.should_not_receive(:add_filters_orchestration)
        @repo.should_not_receive(:remove_filters_orchestration)
        post :update_products, :id=>@filter.id, :repos=>{-1 => -1}
        response.should be_success  #invalid products are ignored
        assert Filter.find(@filter.id).repositories.empty?
      end

      it "should not allow for updating of repos for an invalid filter" do
        @repo.should_not_receive(:add_filters_orchestration)
        @repo.should_not_receive(:remove_filters_orchestration)
        controller.should notify.error
        post :update_products, :id=>"-1", :repos=>{@repo.product.id => @repo.id}
        response.should_not be_success
      end

    end



  end

  describe "rules" do
    before (:each) do
      disable_user_orchestration

      @organization = new_test_org
      @testuser = User.create!(:username=>"TestUser", :password=>"foobar", :email=>"TestUser@somewhere.com")
      @filter = Filter.create!(:name => 'filter1', :organization => @organization)
      @filter2 = Filter.create!(:name=>'filter2', :organization => @organization)
    end
    describe "GET index" do
      let(:action) {:index}
      let(:req) {get 'index' }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :filters, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end

      it_should_behave_like "protected action"
    end


    describe "GET items" do
      let(:action) {:items}
      let(:req) {get 'items' }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :filters, [@filter.id], @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      let(:before_success) do
        controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
          search_options[:filter][:organization_id].should include(@organization.id)
          controller.stub(:render)
        }
      end
      it_should_behave_like "protected action"
    end



    describe "PUT update" do
      let(:action) {:update}
      let(:req) {put 'update', {:id=> @filter.id}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :filters, [@filter.id], @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read, :filters, [@filter.id], @organization) }
      end

      it_should_behave_like "protected action"
    end


    describe "PUT add_packages" do
      let(:action) {:add_packages}
      let(:req) {put 'update', {:id=> @filter.id}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :filters, [@filter.id], @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read, :filters, [@filter.id], @organization) }
      end

      it_should_behave_like "protected action"
    end

    describe "PUT remove_packages" do
      let(:action) {:remove_packages}
      let(:req) {put 'update', {:id=> @filter.id}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :filters, [@filter.id], @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read, :filters, [@filter.id], @organization) }
      end

      it_should_behave_like "protected action"
    end


    describe "PUT update_products" do
      let(:action) {:update_content}
      let(:req) {put 'update_products', {:id=> @filter.id, :products=>{}, :packages=>{}}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :filters, [@filter.id], @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read, :filters, [@filter.id], @organization) }
      end

      it_should_behave_like "protected action"
    end

    describe "PUT create" do
      let(:action) {:create}
      let(:req) {post 'create', {:name=>"FOOBAR"}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:create, :filters, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read, :filters, nil, @organization) }
      end

      it_should_behave_like "protected action"
    end

    describe "DELETE delete" do
      let(:action) {:destroy}
      let(:req) {delete 'destroy', {:id=> @filter.id}}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:delete, :filters, [@filter.id], @organization) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read, :filters, nil, @organization) }
      end
      it_should_behave_like "protected action"
    end


  end

  


end
