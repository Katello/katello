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

describe ActivationKeysController do

  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods


  module AKeyControllerTest
    AKEY_INVALID = {}
    AKEY_NAME_INVALID = {:name => ""}
    AKEY_NAME = {:name => "test key updated"}
    AKEY_DESCRIPTION = {:description => "this is the key's description updated"}
  end

  before(:each) do
    set_default_locale
    login_user
    controller.stub(:search_validate).and_return(true)
    @organization = new_test_org
    @environment_1 = KTEnvironment.create!(:name => 'dev', :prior => @organization.library.id, :organization => @organization)
    @environment_2 = KTEnvironment.create!(:name => 'prod', :prior => @environment_1.id, :organization => @organization)
    @system_template_1 = SystemTemplate.create!(:name => 'template1', :environment => @environment_1)
    @system_template_2 = SystemTemplate.create!(:name => 'template2', :environment => @environment_1)
    @a_key = ActivationKey.create!(:name => "another test key", :organization => @organization, :environment => @environment_1)
    @subscription = KTPool.create!(:cp_id => "Test Subscription",
                                          :key_pools => [KeyPool.create!(:activation_key => @a_key)])

    @akey_params = {:activation_key => { :name => "test key", :description => "this is the test key", :environment_id => @environment_1.id,
                                         :system_template_id => @system_template_1.id}}
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
      controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
        controller.stub(:render)
        search_options[:filter][:organization_id].first.should == @organization.id
      }
      get :items
    end

    it "renders the index for 2 pane" do
      get :index
      response.should render_template(:index)
    end

    it "should be successful" do
      get :index
      response.should be_success
    end
  end

  describe "GET show" do
    describe "with valid activation key id" do
      it "renders a list update partial for 2 pane" do
        get :show, :id => @a_key.id
        response.should render_template(:partial => "common/_list_update")
      end

      it "should be successful" do
        get :show, :id => @a_key.id
        response.should be_success
      end
    end

    describe "with invalid activation key id" do
      it "should generate an error notice" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        get :show, :id => 9999
      end

      it "should be unsuccessful" do
        get :show, :id => 9999
        response.should_not be_success
      end
    end
  end

  describe "GET new" do
    it "instantiates a new key" do
      ActivationKey.should_receive(:new)
      get :new
    end

    it "renders a new partial for 2 pane" do
      get :new
      response.should render_template(:partial => "_new")
    end

    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "GET edit" do
    describe "with valid activation key id" do
      it "renders an edit partial for 2 pane" do
        get :edit, :id => @a_key.id
        response.should render_template(:partial => "_edit")
      end

      it "should be successful" do
        get :edit, :id => @a_key.id
        response.should be_success
      end
    end

    describe "with invalid activation key id" do
      it "should generate an error notice" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        get :edit, :id => 9999
      end

      it "should be unsuccessful" do
        get :edit, :id => 9999
        response.should_not be_success
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created activation_key" do
        post :create, @akey_params
        assigns[:activation_key].name.should eq(@akey_params[:activation_key][:name])
        assigns[:activation_key].description.should eq(@akey_params[:activation_key][:description])
        assigns[:activation_key].environment_id.should eq(@akey_params[:activation_key][:environment_id])
        assigns[:activation_key].system_template_id.should eq(@akey_params[:activation_key][:system_template_id])
      end

      it "renders list item partial for 2 pane" do
        post :create, @akey_params
        response.should render_template(:partial => "common/_list_item")
      end

      it "should generate a success notice" do
        controller.should_receive(:notice)
        post :create, @akey_params
      end

      it "should be successful" do
        post :create, @akey_params
        response.should be_success
      end
      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = @akey_params
          bad_req[:activation_key][:bad_foo] = "mwahaha"
          post :create, bad_req
        end
      end
    end

    describe "with invalid params" do
      it "should generate an error notice" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        post :create, AKeyControllerTest::AKEY_INVALID
      end

      it "should be unsuccessful" do
        post :create, AKeyControllerTest::AKEY_INVALID
        response.should_not be_success
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
        it "should update requested field - name" do
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_NAME
          assigns[:activation_key].name.should eq(AKeyControllerTest::AKEY_NAME[:name])
        end

        it "should update requested field - description" do
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
          assigns[:activation_key].description.should eq(AKeyControllerTest::AKEY_DESCRIPTION[:description])
        end

        it "should update requested field - default environment" do
          put :update, :id => @a_key.id, :activation_key => {:environment_id => @environment_2.id}
          assigns[:activation_key].environment_id.should eq(@environment_2.id)
        end

        it "should update requested field - system template" do
          put :update, :id => @a_key.id, :activation_key => {:system_template_id => @system_template_2.id}
          assigns[:activation_key].system_template_id.should eq(@system_template_2.id)
        end

        it "should generate a success notice" do
          controller.should_receive(:notice)
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
        end

        it "should not redirect from edit view" do
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
          response.should_not be_redirect
        end

        it "should be successful" do
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
          response.should be_success
        end

        it "should successfully add a subscription" do
          controller.should_receive(:notice)
          put :add_subscriptions, { :id => @a_key.id, :subscription_id => {"abc123" => "false"} }
          response.should be_success
          @a_key.pools.where(:cp_id => "abc123").should_not be_empty
          response.should render_template(:partial => "_available_subscriptions_update")
        end

        it "should successfully remove a subscription from the activation key" do
          controller.should_receive(:notice)
          put :remove_subscriptions, { :id => @a_key.id, :subscription_id => {"Test Subscription" => "false"}}
          response.should be_success
          KeyPool.where(:activation_key_id => @a_key.id, :pool_id => @subscription.id).count.should == 0
          response.should render_template(:partial => "_applied_subscriptions_update")
        end

        it "should successfully add an already created subscription to an activation key" do
          controller.should_receive(:notice)
          subscription = KTPool.create!(:cp_id => 'One Time Subscription')
          put :add_subscriptions, { :id => @a_key.id, :subscription_id => {"One Time Subscription" => "false"}}
          response.should be_success
          KeyPool.where(:activation_key_id => @a_key.id, :pool_id => subscription.id).should_not be_empty
          response.should render_template(:partial => "_available_subscriptions_update")
        end

      end

      describe "with invalid params" do
        it_should_behave_like "bad request"  do
          let(:req) do
            bad_req = {:id => @a_key.id, :activation_key => {:name => "bar", :bad_foo => "hahaha"}}
            put :update, bad_req
          end
        end
        it "should generate an error notice" do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_NAME_INVALID
        end

        it "should be unsuccessful" do
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_NAME_INVALID
          response.should_not be_success
        end
      end
    end

    describe "with invalid activation key id" do
      it "should generate an error notice" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        put :update, :id => 9999, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
      end

      it "should be unsuccessful" do
        put :update, :id => 9999, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
        response.should_not be_success
      end

      it "should be unsuccessful at adding a subscription" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        put :add_subscriptions, { :id => 999, :subscription_id => { "abc123" => "false"}}
        response.should_not be_success
      end

      it "should be unsuccessful at removing a subscription" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        put :remove_subscriptions, { :id => 999, :subscription_id => { "abc123" => "false"}}
        response.should_not be_success
      end

    end
  end

  describe "DELETE destroy" do
    describe "with valid activation key id" do
      before (:each) do
        controller.stub!(:render).and_return("") #ignore missing list_remove js partial
      end

      it "should delete the key" do
        delete :destroy, :id => @a_key.id
        ActivationKey.exists?(@a_key.id).should be_false
      end

      it "should generate a success notice" do
        controller.should_receive(:notice)
        delete :destroy, :id => @a_key.id
      end

      it "should be successful" do
        delete :destroy, :id => @a_key.id
        response.should be_success
      end
    end

    describe "with invalid activation key id" do
      it "should generate an error notice" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        delete :destroy, :id => 9999
      end

      it "should be unsuccessful" do
        delete :destroy, :id => 9999
        response.should_not be_success
      end
    end
  end
end
