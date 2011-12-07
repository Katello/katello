require 'spec_helper'

describe FiltersController, :katello => true do


  include LoginHelperMethods
  include LocaleHelperMethods
  include ProductHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper


  before(:each) do

      set_default_locale
      login_user
      disable_filter_orchestration
      disable_product_orchestration

  end


  describe "Controller tests" do
    before(:each) do
      @organization = new_test_org
      @filter = Filter.create!(:name => 'filter', :organization => @organization)
      @env = @organization.locker
      @product = new_test_product(@organization, @env)
    end

    describe "GET index" do
      it "requests filters using search criteria" do
        get :index
        response.should be_success
      end
    end

    describe "GET items" do
      it "requests filters using search criteria" do

        get :items
        response.should be_success
        assigns(:items)
      end
    end

    describe "create filter" do
      it "posts to create a filter should be sucessful" do
        controller.should_receive(:notice)
        post :create, :filter => {:name=>"testfilter"}
        response.should be_success
        Filter.where(:pulp_id=>"testfilter").first.pulp_id.should == "testfilter"
      end

      it "posts to create a filter should not be sucessful if no name" do
        controller.should_receive(:errors)
        post :create, :filter => {}
        response.should_not be_success
      end

    end


    describe "edit a filter" do
      it "should recieve a valid filter for edit" do
        get :edit, :id=>@filter.id
        response.should be_success
      end

      it "should not recieve a valid filter for edit a non-existant id" do
        controller.should_receive(:errors)
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
        controller.should_receive(:errors)
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
        controller.should_receive(:errors)
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
        controller.should_receive(:notice)
        @filter.should_receive(:destroy)
        controller.stub(:render) #can't find common
        delete :destroy, :id=>@filter.id
        response.should be_success
      end
      
      it "should not be successful with a valid filter" do
        controller.should_receive(:errors)
        delete :destroy, :id=>-12343
        response.should_not be_success
      end

    end

    describe "Set products" do
      it "should allow for updating of products for a valid product" do
        controller.should_receive(:notice)
        post :update_products, :id=>@filter.id, :products=>[@product.id]
        response.should be_success
        assert !Filter.find(@filter.id).products.empty?
      end

      it "should allow for updating of products for a empty products" do
        @filter.products << @product
        @filter.save!
        controller.should_receive(:notice)
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
        controller.should_receive(:errors)
        post :update_products, :id=>"-1", :products=>[@product.id]
        response.should_not be_success
      end
      
    end

    describe "Auto complete products" do
      it "should return a valid product" do
        get :auto_complete_products_repos, :term=>@product.name
        response.should be_success
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
      let(:on_success) do
        assigns(:items).should_not include @filter2
        assigns(:items).should include @filter
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
