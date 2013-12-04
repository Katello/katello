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
describe Api::V1::ActivationKeysController do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include OrganizationHelperMethods

  let(:user_with_read_permissions) { user_with_permissions { |u| u.can(:read_all, :activation_keys) } }
  let(:user_without_read_permissions) { user_without_permissions }
  let(:user_with_manage_permissions) { user_with_permissions { |u| u.can(:manage_all, :activation_keys) } }
  let(:user_without_manage_permissions) { user_with_permissions { |u| u.can(:read_all, :activation_keys) } }

  before(:each) do
    setup_controller_defaults_api
    @request.env["HTTP_ACCEPT"] = "application/json"
    disable_org_orchestration
    disable_consumer_group_orchestration

    @organization = Organization.create! do |o|
      o.id    = '1234'
      o.name  = "org-1234"
      o.label = "org-1234"
    end

    @environment    = KTEnvironment.new(:organization => @organization)
    @activation_key = ActivationKey.new(:name => 'activation key')
  end

  context "before_filter :find_activation_key should retrieve activation key" do
    before { ActivationKey.expects(:find).once.with('123').returns(@activation_key) }

    specify { get :show, :id => '123' }
    specify { put :update, :id => '123', :activation_key => { :description => "genius" } }
    specify { delete :destroy, :id => '123' }
  end

  it "before_filter :find_activation_key should return a 404 if activation key wasn't found" do
    ActivationKey.stubs(:find).returns(nil)

    get :show, :id => 123
    response.status.must_equal 404
  end

  context "before_filter :find_environment should retrieve environment" do
    before do
      KTEnvironment.expects(:find).once.with('123').returns(@environment)
    end

    specify { get :index, :environment_id => '123' }
    specify { post :create, :environment_id => '123', :activation_key => { :description => "gah" } }
  end

  it "before_filter :find_environment should return 404 if environment wasn't found" do
    KTEnvironment.stubs(:find).returns(nil)

    get :index, :environment_id => 123
    response.status.must_equal 404
  end

  context "show all activation keys" do
    before(:each) do
      Organization.stubs(:first).returns(@organization)
      ActivationKey.stubs(:where).returns([@activation_key])
    end

    let(:action) { :index }
    let(:req) { get :index, :organization_id => 'org-1234' }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should retrieve organization" do
      @controller.expects(:find_optional_organization)
      get :index, :organization_id => '1234'
    end

    it "should retrieve all keys in organization" do
      @controller.expects(:find_optional_organization)
      get :index, :organization_id => '1234'
    end

    it "should return all keys in organization" do
      json = [@activation_key].to_json
      get :index, :organization_id => 'org-1234'
      response.body.must_equal json
    end
  end

  context "show an activation key" do
    before { ActivationKey.stubs(:find).returns(@activation_key) }

    let(:action) { :show }
    let(:req) { get :show, :id => '123' }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should return json representation of the activation key" do
      json = "Test Json"
      @activation_key.expects(:to_json).once.returns(json)
      get :show, :id => 123
      response.body.must_equal json
    end
  end

  context "create an activation key" do
    before(:each) do
      KTEnvironment.stubs(:find).returns(@environment)
      ActivationKey.stubs(:find).returns(@activation_key)
    end

    let(:action) { :create }
    let(:req) { post :create, :environment_id => 123, :activation_key => { :name => 'blah' } }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should create an activation key" do
      ActivationKey.expects(:create!).once.with(has_entry("name" => 'blah')).returns(@activation_key)
      post :create, :environment_id => 123, :activation_key => { :name => 'blah' }
    end

    it "should create a key with a content view" do
      @content_view                = FactoryGirl.build_stubbed(:content_view)
      @activation_key.content_view = @content_view
      ActivationKey.expects(:create!).once.with(
          has_entry("content_view_id" => @content_view.id.to_s)
      ).returns(@activation_key)

      post :create, :environment_id => 123, :activation_key => { :name => 'blah', :content_view_id => @content_view.id.to_s }
    end

    it "should return created key" do
      ActivationKey.stubs(:create!).returns(@activation_key)
      json = "bwahahahaha"
      @activation_key.expects(:to_json).once.returns(json)
      post :create, :environment_id => 123, :activation_key => { :name => "egypt", :description => "gah" }

      response.body.must_equal json
    end

    describe "invalid create params" do
      let(:req) do
        bad_req = { :environment_id => 123,
                    :activation_key =>
                        { :bad_foo     => "mwahahaha",
                          :name        => "Gpg Key",
                          :description => "This is the key string" }
        }.with_indifferent_access
        post :create, bad_req
      end
      it_should_behave_like "bad request"
    end

    describe "invalid create params1" do
      let(:req) do
        bad_req = { :environment_id => 1,
                    :activation_key =>
                        { :name        => "Gpg Key",
                          :usage_limit => "-666" }
        }.with_indifferent_access
        post :create, bad_req
      end
      it_should_behave_like "bad request"
    end

  end

  context "update an activation key" do
    before(:each) do
      ActivationKey.stubs(:find).returns(@activation_key)
      @activation_key.stubs(:update_attributes!).returns(@activation_key)
    end

    let(:action) { :update }
    let(:req) { put :update, :id => 123, :activation_key => { :name => 'blah' } }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should update activation key" do
      @activation_key.expects(:update_attributes!).once.returns(@activation_key).with(has_entries("name" =>"blah"))
      put :update, :id => 123, :activation_key => { :name => 'blah' }
    end

    it "should return updated key" do
      json = "bwahahahaha"
      @activation_key.expects(:to_json).once.returns(json)
      put :update, :id => 123, :activation_key => { :name => 'blah' }
      response.body.must_equal json
    end

    describe "invalid params" do
      let(:req) do
        bad_req = { :id             => 123,
                    :activation_key =>
                        { :bad_foo     => "mwahahaha",
                          :name        => "Gpg Key",
                          :description => "This is the key string" }
        }.with_indifferent_access
        put :update, bad_req

      end
      it_should_behave_like "bad request"
    end
  end

  context "pools in an activation key" do

    before(:each) do
      @environment                = create_environment(:organization => @organization, :name => "Dev", :label => "Dev", :prior => @organization.library)
      @activation_key             = create_activation_key(:name => 'activation key', :organization => @organization, :environment => @environment)
      @pool_in_activation_key     = Katello::Pool.create!(:cp_id => "pool-123")
      @pool_not_in_activation_key = Katello::Pool.create!(:cp_id => "pool-456")

      disable_pools_orchestration
      KeyPool.create!(:activation_key_id => @activation_key.id, :pool_id => @pool_in_activation_key.id)
      ActivationKey.stubs(:find).returns(@activation_key)
      Katello::Pool.stubs(:find_by_organization_and_id).with(@organization, "pool-123" ).returns(@pool_in_activation_key)
      Katello::Pool.stubs(:find_by_organization_and_id).with(@organization, "pool-456" ).returns(@pool_not_in_activation_key)
    end

    describe "adding a pool" do

      let(:action) { :add_pool }
      let(:req) { post :add_pool, :id => 123, :poolid => @pool_not_in_activation_key.cp_id }
      let(:authorized_user) { user_with_manage_permissions }
      let(:unauthorized_user) { user_without_manage_permissions }
      it_should_behave_like "protected action"

      it "should add pool to the activation key" do
        req
        @activation_key.pools.must_include(@pool_in_activation_key)
        @activation_key.pools.must_include(@pool_not_in_activation_key)
        @activation_key.pools.size.must_equal(2)
      end

      it "should not add a pool that is already in the activation key" do
        Katello::Pool.stubs(:find_by_organization_and_id => @pool_in_activation_key)
        req
        @activation_key.pools.must_include(@pool_in_activation_key)
        @activation_key.pools.size.must_equal(1)
      end

      it "should return updated key" do
        json = "Test Json"
        @activation_key.expects(:to_json).once.returns(json)
        req
        response.body.must_equal json
      end
    end

    describe "removing a pool" do

      let(:action) { :remove_pool }
      let(:req) { delete :remove_pool, :id => 123, :poolid => @pool_in_activation_key.cp_id }
      let(:authorized_user) { user_with_manage_permissions }
      let(:unauthorized_user) { user_without_manage_permissions }
      it_should_behave_like "protected action"

      it "should add pool to the activation key" do
        req
        @activation_key.pools.must_be_empty
      end

      it "should return 404 if pool in not in the activation key" do
        delete :remove_pool, :id => 123, :poolid => @pool_not_in_activation_key.cp_id
        response.code.must_equal "404"
      end

      it "should return updated key" do
        json = "Test Json"
        @activation_key.expects(:to_json).once.returns(json)
        req
        response.body.must_equal json
      end

    end

  end

  context "delete an activation key" do
    before(:each) do
      ActivationKey.stubs(:find).returns(@activation_key)
      @activation_key.stubs(:destroy)
    end

    let(:action) { :destroy }
    let(:req) { delete :destroy, :id => 123 }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should destroy activation key" do
      @activation_key.expects(:destroy).once
      delete :destroy, :id => 123
    end

    it "should return a 204" do
      delete :destroy, :id => 123
      response.status.must_equal 204
    end
  end

  describe "add system groups to an activation key" do
    before(:each) do
      @environment    = create_environment(:name => 'test_1', :label => 'test_1', :prior => @organization.library.id, :organization => @organization)
      @activation_key = create_activation_key(:name => 'activation key', :environment => @environment, :organization => @organization)
      @system_group_1 = SystemGroup.create!(:name => 'System Group 1', :organization_id => @organization.id)
      @system_group_2 = SystemGroup.create!(:name => 'System Group 2', :description => "fake description", :organization => @organization)
    end

    let(:action) { :add_system_groups }
    let(:req) { post :add_system_groups, :id => @activation_key.id, :organization_id => @organization.label }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should update the system groups attached to the activation key" do
      ids = [@system_group_1.id, @system_group_2.id]
      post :add_system_groups, :id => @activation_key.id, :organization_id => @organization.label, :activation_key => { :system_group_ids => ids }
      must_respond_with(:success)
      ActivationKey.find(@activation_key.id).system_group_ids.must_include(@system_group_1.id)
      ActivationKey.find(@activation_key.id).system_group_ids.must_include(@system_group_2.id)
    end

    it "should throw a 404 is passed in a bad system group id" do
      ids = [90210]
      post :add_system_groups, :id => @activation_key.id, :organization_id => @organization.id.to_s, :activation_key => { :system_group_ids => ids }
      response.status.must_equal 404
    end

  end

  describe "remove system groups from an activation key" do
    before(:each) do
      @environment    = create_environment(:name => 'test_1', :label => 'test_1', :prior => @organization.library.id, :organization => @organization)
      @activation_key = create_activation_key(:name => 'activation key', :environment => @environment, :organization => @organization)
      @system_group_1 = SystemGroup.create!(:name => 'System Group 1', :organization_id => @organization.id)
      @system_group_2 = SystemGroup.create!(:name => 'System Group 2', :description => "fake description", :organization => @organization)
      @activation_key.system_group_ids << [@system_group_1.id, @system_group_2.id]
      @activation_key.save!
    end

    let(:action) { :remove_system_groups }
    let(:req) { delete :remove_system_groups, :id => @activation_key.id, :organization_id => @organization.label }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should update the system groups the system is in" do
      ids = [@system_group_1.id, @system_group_2.id]
      delete :remove_system_groups, :id => @activation_key.id, :organization_id => @organization.label, :system => { :system_group_ids => ids }
      @activation_key.system_group_ids.must_be_empty
    end

    it "should throw a 404 is passed in a bad system group id" do
      ids = [90210]
      delete :remove_system_groups, :id => @activation_key.id, :organization_id => @organization.label, :activation_key => { :system_group_ids => ids }
      response.status.must_equal 404
    end
   end
end
end