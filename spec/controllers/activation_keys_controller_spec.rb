#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
describe ActivationKeysController do

  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper

  module AKeyControllerTest
    AKEY_INVALID = {}
    AKEY_NAME_INVALID = {:name => ""}
    AKEY_NAME = {:name => "test key updated"}
    AKEY_DESCRIPTION = {:description => "this is the key's description updated"}
  end

  before(:each) do
    @routes = Katello::Engine.routes
    set_default_locale

    session[:user] = User.current ? User.current.id : users(:admin)
    session[:expires_at] = 5.minutes.from_now
    @organization = new_test_org

    @controller.stubs(:require_org).returns(true)
    @controller.stubs(:current_organization).returns(@organization)

    Resources::Candlepin::Pool.stubs(:find).returns(true)
    @environment_1 = create_environment(:name=>'dev', :label=> 'dev', :prior => @organization.library.id, :organization => @organization)
    @environment_2 = create_environment(:name=>'prod', :label=> 'prod', :prior => @environment_1.id, :organization => @organization)
    @a_key = create_activation_key(:name => "another test key", :organization => @organization, :environment => @environment_1)
    @subscription = Pool.create!(:cp_id => "Test Subscription",
                                          :key_pools => [KeyPool.create!(:activation_key => @a_key)])

    @akey_params = {:activation_key => { :name => "test key", :description => "this is the test key",
                                         :environment_id => @environment_1.id,
                                         :content_view_id => @environment_1.content_views.first.id}} if Katello.config.katello?
    @akey_params = {:activation_key => { :name => "test key", :description => "this is the test key",
                                        :environment_id => @organization.library.id}} unless Katello.config.katello?
  end

  describe "rules" do
    let(:action) {:items }
    let(:req) { get :items }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:read_all, :activation_keys) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"
  end

  describe "GET index" do
    it "attempts to retain request in search history" do
      @controller.expects(:render_panel_direct)
      @controller.stubs(:render).returns("")
      get :items
    end

    it "renders the index for 2 pane" do
      get :index
      must_render_template(:index)
    end

    it "should be successful (katello)" do#TODO headpin
      get :index
      must_respond_with(:success)
    end
  end

  describe "GET show" do
    describe "with valid activation key id" do
      it "renders a list update partial for 2 pane" do
        get :show, :id => @a_key.id
        must_render_template(:partial => "katello/activation_keys/_activation_key")
      end

      it "should be successful" do
        get :show, :id => @a_key.id
        must_respond_with(:success)
      end
    end

    describe "with invalid activation key id" do
      it "should generate an error notice (katello)" do #TODO headpin
        must_notify_with :error
        get :show, :id => 9999
      end

      it "should be unsuccessful (katello)" do #TODO headpin
        get :show, :id => 9999
        must_respond_with(404)
      end
    end
  end

  describe "GET new" do
    it "renders a new partial for 2 pane" do
      get :new
      must_render_template(:partial => "_new")
    end

    it "should be successful" do
      get :new
      must_respond_with(:success)
    end
  end

  describe "GET edit" do
    describe "with valid activation key id" do
      it "renders an edit partial for 2 pane" do
        get :edit, :id => @a_key.id
        must_render_template(:partial => "_edit")
      end

      it "should be successful" do
        get :edit, :id => @a_key.id
        must_respond_with(:success)
      end
    end

    describe "with invalid activation key id" do
      it "should generate an error notice" do
        must_notify_with :error
        get :edit, :id => 9999
      end

      it "should be unsuccessful (katello)" do #TODO headpin
        get :edit, :id => 9999
        must_respond_with(404)
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created activation_key (katello)" do #TODO headpin
        post :create, @akey_params
        assigns[:activation_key].name.must_equal(@akey_params[:activation_key][:name])
        assigns[:activation_key].description.must_equal(@akey_params[:activation_key][:description])
        assigns[:activation_key].environment_id.must_equal(@akey_params[:activation_key][:environment_id])
      end

      it "should generate a success notice" do
        must_notify_with :success
        post :create, @akey_params
      end

      it "should be successful (katello)" do #TODO headpin
        post :create, @akey_params
        must_respond_with(:success)
      end
      let(:req) do
        it_should_behave_like "bad request"  do
          bad_req = @akey_params
          bad_req[:activation_key][:bad_foo] = "mwahaha"
          post :create, bad_req
        end
      end
    end

    describe "with invalid params" do
      it "should generate an error notice" do
        must_notify_with :exception
        post :create, AKeyControllerTest::AKEY_INVALID
      end

      it "should be unsuccessful (katello)" do #TODO headpin
        post :create, AKeyControllerTest::AKEY_INVALID
        must_respond_with(422)
      end
    end
  end

  describe "PUT update" do

    let(:action) { :update }
    let(:req) { put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_NAME }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:manage_all, :activation_keys) }
    end
    let(:unauthorized_user) do
      user_with_permissions { |u| u.can(:read_all, :activation_keys) }
    end
    it_should_behave_like "protected action"

    describe "with valid activation key id" do
      describe "with valid params" do
        it "should update requested field - name (katello)" do #TODO headpin
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_NAME
          assigns[:activation_key].name.must_equal(AKeyControllerTest::AKEY_NAME[:name])
        end

        it "should update requested field - description (katello)" do #TODO headpin
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
          assigns(:activation_key).description.must_equal(AKeyControllerTest::AKEY_DESCRIPTION[:description])
        end

        it "should update requested field - default environment (katello)" do #TODO headpin
          put :update, :id => @a_key.id, :activation_key => {:environment_id => @environment_2.id}
          assigns(:activation_key).environment_id.must_equal(@environment_2.id)
        end

        it "should generate a success notice" do
          must_notify_with :success
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
        end

        it "should not redirect from edit view (katello)" do #TODO headpin
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
          must_respond_with(:success)
        end

        it "should be successful (katello)" do #TODO headpin
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
          must_respond_with(:success)
        end

        it "should successfully add a subscription" do
          must_notify_with :success
          put :add_subscriptions, { :id => @a_key.id, :subscription_id => {"abc123" => "false"} }
          must_respond_with(:success)
          @a_key.pools.where(:cp_id => "abc123").wont_be :empty?
          must_render_template(:js => "_available_subscriptions_update")
        end

        it "should successfully remove a subscription from the activation key" do
          must_notify_with(:success)
          put :remove_subscriptions, {:id => @a_key.id, :subscription_id => {"Test Subscription" => "false"}}
          must_respond_with(:success)
          KeyPool.where(:activation_key_id => @a_key.id, :pool_id => @subscription.id).count.must_equal(0)
        end

        it "should successfully add an already created subscription to an activation key" do
          must_notify_with :success
          subscription = Pool.create!(:cp_id => 'One Time Subscription')
          put :add_subscriptions, { :id => @a_key.id, :subscription_id => {"One Time Subscription" => "false"}}
          must_respond_with(:success)
          KeyPool.where(:activation_key_id => @a_key.id, :pool_id => subscription.id).wont_be :empty?
          must_render_template(:js => "_available_subscriptions_update")
        end

      end

      describe "with invalid params" do
        it "should generate an error notice" do
          must_notify_with :exception
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_NAME_INVALID
        end

        it "should be unsuccessful (katello)" do #TODO headpin
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_NAME_INVALID
          must_respond_with(422)
        end
      end
    end

    describe "with invalid activation key id" do
      it "should generate an error notice" do
        must_notify_with :error
        put :update, :id => 9999, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
      end

      it "should be unsuccessful (katello)" do #TODO headpin
        put :update, :id => 9999, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
        must_respond_with(404)
      end

      it "should be unsuccessful at adding a subscription (katello)" do #TODO headpin
        must_notify_with :error
        put :add_subscriptions, { :id => 999, :subscription_id => { "abc123" => "false"}}
        must_respond_with(404)
      end

      it "should be unsuccessful at removing a subscription" do
        must_notify_with :error
        put :remove_subscriptions, { :id => 999, :subscription_id => { "abc123" => "false"}}
        must_respond_with(404)
      end

    end
  end

  describe "GET system_groups" do
    before(:each) do
      disable_consumer_group_orchestration
      @group = SystemGroup.create!(:name=>"test_group", :organization=>@organization)
    end

    it "retrieves the system groups to display (katello)" do #TODO headpin
      SystemGroup.
          expects(:where).
          with(:organization_id => @organization).
          returns(mock(:order => []))
      get :system_groups, :id => @a_key.id
    end

    it "renders the system_group partial" do
      get :system_groups, :id => @a_key.id
      must_render_template(:partial => "_system_groups")
    end

    it "should be successful" do
      get :system_groups, :id => @a_key.id
      must_respond_with(:success)
    end
  end

  describe "GET systems" do
    before(:each) do
      @system = System.new(:name => "test_system", :environment => @environment_1, :cp_type=>"system", :facts=>{"Test" => ""})
      ActivationKey.stubs(:find).with(@a_key.id.to_s).returns(@a_key)
      @a_key.expects(:systems).returns([@system])
    end

    it "retrieves the systems to display" do
      get :systems, :id => @a_key.id.to_s
      must_respond_with(:success)
    end

    it "renders the systems partial" do
      get :systems, :id => @a_key.id.to_s
      must_render_template(:partial => "_systems")
      must_respond_with(:success)
    end

    it "should be successful" do
      get :systems, :id => @a_key.id.to_s
      must_respond_with(:success)
    end
  end

  describe "PUT add_system_groups" do
    before(:each) do
      disable_consumer_group_orchestration
      @group = SystemGroup.create!(:name=>"test_group", :organization=>@organization)
    end

    it "should allow system groups to be added to the key (katello)" do #TODO headpin
      assert ActivationKey.find(@a_key.id).system_groups.size == 0
      put 'add_system_groups', {:id => @a_key.id, :group_ids=>[@group.id]}
      must_respond_with(:success)
      assert ActivationKey.find(@a_key.id).system_groups.size == 1
    end

    it "should generate a success notice" do
      must_notify_with :success
      put 'add_system_groups', {:id => @a_key.id, :group_ids=>[@group.id]}
    end

    it "should be successful (katello)" do #TODO headpin
      put 'add_system_groups', {:id => @a_key.id, :group_ids=>[@group.id]}
      must_respond_with(:success)
    end
  end

  describe "PUT remove_system_groups" do
    before(:each) do
      disable_consumer_group_orchestration
      @group = SystemGroup.create!(:name=>"test_group", :organization=>@organization)
      @a_key.system_groups = [@group]
      @a_key.save!
    end

    it "should allow system groups to be removed from the key (katello)" do #TODO headpin
      assert ActivationKey.find(@a_key.id).system_groups.size == 1
      put 'remove_system_groups', {:id => @a_key.id, :group_ids=>[@group.id]}
      must_respond_with(:success)
      assert ActivationKey.find(@a_key.id).system_groups.size == 0
    end

    it "should generate a success notice" do
      must_notify_with :success
      put 'remove_system_groups', {:id => @a_key.id, :group_ids=>[@group.id]}
    end

    it "should be successful (katello)" do #TODO headpin
      put 'remove_system_groups', {:id => @a_key.id, :group_ids=>[@group.id]}
      must_respond_with(:success)
    end
  end

  describe "DELETE destroy" do
    describe "with valid activation key id" do
      before (:each) do
        @controller.stubs(:render).returns("") #ignore missing list_remove js partial
      end

      it "should delete the key (katello)" do #TODO headpin
        delete :destroy, :id => @a_key.id
        ActivationKey.exists?(@a_key.id).must_equal false
      end

      it "should generate a success notice" do
        must_notify_with :success
        delete :destroy, :id => @a_key.id
      end

      it "should be successful (katello)" do #TODO headpin
        delete :destroy, :id => @a_key.id
        must_respond_with(:success)
      end
    end

    describe "with invalid activation key id" do
      it "should generate an error notice" do
        must_notify_with :error
        delete :destroy, :id => 9999
      end

      it "should be unsuccessful (katello)" do #TODO headpin
        delete :destroy, :id => 9999
        must_respond_with(404)
      end
    end
  end

  it "GET available_subscriptions" do
    skip ""
    before(:each) do
      @product1 = Product.new(name: "Product1", :cp_id => "Product1")
      @marketing_product = Product.new(name: "MarketingProduct", :cp_id => "MarketingProduct")
      @custom_product = Product.new(name: "CustomProduct", :cp_id => "CustomProduct")

      @custom_product.stubs(:custom?).returns(true)
      @product1.stubs(:custom?).returns(false)
      @product1.stubs(:marketing_products).returns([@marketing_product])
      @products = [@product1, @marketing_product, @custom_product]

      pools = @products.map do |product|
        pool = Pool.create!(:cp_id => product.cp_id,
                            :product_id => product.cp_id)
        pool.stubs(:product_name).returns(product.name)
        pool
      end

      Pool.stubs(:find_pool) { |id, _| pools.detect { |pool| pool.id == id } }
      Product.stubs(:where) { |prod_hash| @products.select {|prod| prod.cp_id == prod_hash[:cp_id] } }

      ActivationKey.stubs(:find).with(@a_key.id.to_s).returns(@a_key)
      Resources::Candlepin::Owner.stubs(:pools).returns(pools)
      @a_key.stub_chain(:content_view, :products).returns(@products - [@marketing_product])
    end

    let(:action) { :available_subscriptions }
    let(:req) { get :available_subscriptions, :id => @a_key.id }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:read_all, :activation_keys, @a_key.id) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"

    it "should create a mapping with marketing_product and custom_product" do
      get :available_subscriptions, :id => @a_key.id.to_s
      must_respond_with(:success)
      must_render_template(:partial => "_available_subscriptions")

      available_products = [@custom_product.name, @marketing_product.name].sort
      assigns[:available_pools].map { |arr| arr.first }.sort.must_equall(available_products)
    end
  end

end
end
