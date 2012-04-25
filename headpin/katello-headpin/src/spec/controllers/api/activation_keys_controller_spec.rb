#
# Copyright 2011 Red Hat, Inc.
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

describe Api::ActivationKeysController do
  include LoginHelperMethods
  include AuthorizationHelperMethods

  let(:user_with_read_permissions) { user_with_permissions { |u| u.can(:read_all, :activation_keys) } }
  let(:user_without_read_permissions) { user_without_permissions }
  let(:user_with_manage_permissions) { user_with_permissions { |u| u.can(:manage_all, :activation_keys) } }
  let(:user_without_manage_permissions) { user_with_permissions { |u| u.can(:read_all, :activation_keys) } }

  before(:each) do
    login_user_api
    @request.env["HTTP_ACCEPT"] = "application/json"
    disable_org_orchestration

    @organization = Organization.create! do |o|
      o.id = 1234
      o.name = "org-1234"
      o.cp_key = "org-1234"
    end

    @environment = KTEnvironment.new(:organization => @organization)
    @activation_key = ActivationKey.new(:name => 'activation key')
  end

  context "before_filter :find_activation_key should retrieve activation key" do
    before { ActivationKey.should_receive(:find).once.with(123).and_return(@activation_key) }

    specify { get :show, :id => 123 }
    specify { put :update, :id => 123, :activation_key => {:description => "genius"} }
    specify { delete :destroy, :id => 123 }
  end

  it "before_filter :find_activation_key should return a 404 if activation key wasn't found" do
    ActivationKey.stub!(:find).and_return(nil)

    get :show, :id => 123
    response.status.should == 404
  end

  context "before_filter :find_environment should retrieve environment" do
    before do
      KTEnvironment.should_receive(:find).once.with(123).and_return(@environment)
    end

    specify { get :index, :environment_id => 123 }
    specify { post :create, :environment_id => 123, :activation_key=> {:description => "gah"} }
  end

  it "before_filter :find_environment should return 404 if environment wasn't found" do
    KTEnvironment.stub!(:find).and_return(nil)

    get :index, :environment_id => 123
    response.status.should == 404
  end

  context "show all activation keys" do
    before(:each) do
      Organization.stub!(:first).and_return(@organization)
      ActivationKey.stub!(:where).and_return([@activation_key])
    end

    let(:action) {:index }
    let(:req) { get :index, :organization_id => '1234'  }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should retrieve organization" do
      Organization.should_receive(:first).once.with(hash_including(:conditions => {:cp_key => '1234'})).and_return(@organization)
      get :index, :organization_id => '1234'
    end

    it "should retrieve all keys in organization" do
      ActivationKey.should_receive(:where).once.with(hash_including(:organization_id => 1234)).and_return([@activation_key])
      get :index, :organization_id => '1234'
    end

    it "should return all keys in organization" do
      get :index, :organization_id => '1234'
      response.body.should == [@activation_key].to_json
    end
  end

  context "show an activation key" do
    before { ActivationKey.stub!(:find).and_return(@activation_key) }

    let(:action) {:show }
    let(:req) { get :show, :id => '123'  }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should return json representation of the activation key" do
      get :show, :id => 123
      response.body.should == @activation_key.to_json
    end
  end

  context "create an activation key" do
    before(:each) do
      KTEnvironment.stub!(:find).and_return(@environment)
      ActivationKey.stub!(:find).and_return(@activation_key)
    end

    let(:action) {:create }
    let(:req) { post :create, :environment_id => 123, :activation_key => {:name => 'blah'} }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should create an activation key" do
      ActivationKey.should_receive(:create!).once.with(hash_including(:name => 'blah')).and_return(@activation_key)
      post :create, :environment_id => 123, :activation_key => {:name => 'blah'}
    end

    it "should return created key" do
      ActivationKey.stub!(:create!).and_return(@activation_key)
      post :create, :environment_id => 123, :activation_key=> {:name=>"egypt", :description => "gah"}

      response.body.should == @activation_key.to_json
    end

    it_should_behave_like "bad request"  do
      let(:req) do
        bad_req = {:environment_id => 123,
                   :activation_key =>
                      {:bad_foo => "mwahahaha",
                       :name => "Gpg Key",
                       :description => "This is the key string" }
        }.with_indifferent_access
        post :create, bad_req
      end
    end
  end

  context "update an activation key" do
    before(:each) do
      ActivationKey.stub!(:find).and_return(@activation_key)
      @activation_key.stub!(:update_attributes!).and_return(@activation_key)
    end

    let(:action) {:update }
    let(:req) { put :update, :id => 123, :activation_key => {:name => 'blah'} }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should update activation key" do
      @activation_key.should_receive(:update_attributes!).once.with(hash_including(:name => 'blah')).and_return(@activation_key)
      put :update, :id => 123, :activation_key => {:name => 'blah'}
    end

    it "should return updated key" do
      put :update, :id => 123, :activation_key => {:name => 'blah'}
      response.body.should == @activation_key.to_json
    end

    it_should_behave_like "bad request"  do
      let(:req) do
        bad_req = {:id => 123,
                   :activation_key =>
                      {:bad_foo => "mwahahaha",
                       :name => "Gpg Key",
                       :description => "This is the key string" }
        }.with_indifferent_access
        put :update, bad_req
      end
    end
  end

  context "pools in an activation key" do

    before(:each) do
      @environment = KTEnvironment.create!(:organization => @organization, :name => "Dev", :prior => @organization.library)
      @activation_key = ActivationKey.create!(:name => 'activation key', :organization => @organization, :environment => @environment)
      @pool_in_activation_key = KTPool.create!(:cp_id => "pool-123")
      @pool_not_in_activation_key = KTPool.create!(:cp_id => "pool-456")

      KeyPool.create!(:activation_key_id => @activation_key.id, :pool_id => @pool_in_activation_key.id)
      ActivationKey.stub!(:find).and_return(@activation_key)
      KTPool.stub(:find_by_organization_and_id).and_return do |org,poolid|
       case poolid
       when "pool-123" then @pool_in_activation_key
       when "pool-456" then @pool_not_in_activation_key
       else raise "Not found"
       end
      end
    end

    describe "adding a pool" do

      let(:action) {:add_pool }
      let(:req) { post :add_pool, :id => 123, :poolid => @pool_not_in_activation_key.cp_id }
      let(:authorized_user) { user_with_manage_permissions }
      let(:unauthorized_user) { user_without_manage_permissions }
      it_should_behave_like "protected action"

      it "should add pool to the activation key" do
        req
        @activation_key.pools.should include(@pool_in_activation_key)
        @activation_key.pools.should include(@pool_not_in_activation_key)
        @activation_key.pools.should have(2).pools
      end

      it "should not add a pool that is already in the activation key" do
        KTPool.stub(:find_by_organization_and_id => @pool_in_activation_key)
        req
        @activation_key.pools.should include(@pool_in_activation_key)
        @activation_key.pools.should have(1).pool
      end

      it "should return updated key" do
        req
        response.body.should == @activation_key.to_json
      end

    end

    describe "removing a pool" do

      let(:action) {:remove_pool }
      let(:req) { delete :remove_pool, :id => 123, :poolid => @pool_in_activation_key.cp_id }
      let(:authorized_user) { user_with_manage_permissions }
      let(:unauthorized_user) { user_without_manage_permissions }
      it_should_behave_like "protected action"

      it "should add pool to the activation key" do
        req
        @activation_key.pools.should be_empty
      end

      it "should return 404 if pool in not in the activation key" do
        delete :remove_pool, :id => 123, :poolid => @pool_not_in_activation_key.cp_id
        response.code.should == "404"
      end

      it "should return updated key" do
        req
        response.body.should == @activation_key.to_json
      end

    end

  end

  context "delete an activation key" do
    before(:each) do
      ActivationKey.stub!(:find).and_return(@activation_key)
      @activation_key.stub!(:destroy)
    end

    let(:action) {:destroy }
    let(:req) { delete :destroy, :id => 123 }
    let(:authorized_user) { user_with_manage_permissions }
    let(:unauthorized_user) { user_without_manage_permissions }
    it_should_behave_like "protected action"

    it "should destroy activation key" do
      @activation_key.should_receive(:destroy).once
      delete :destroy, :id => 123
    end

    it "should return a 204" do
      delete :destroy, :id => 123
      response.status.should == 204
    end
  end

end
