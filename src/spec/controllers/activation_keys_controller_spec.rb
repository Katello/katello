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

  module AKeyControllerTest
    AKEY = {:activation_key_name => "test key", :activation_key_description => "this is the test key"}
    AKEY_INVALID = {}
    AKEY_NAME_INVALID = {:name => ""}
    AKEY_DESCRIPTION = {:description => "this is the key's description"}
  end

  before(:each) do
    set_default_locale
    login_user

    @organization = new_test_org
    @a_key = ActivationKey.create!(:name=>"another test key", :organization_id=>@organization)
  end

  describe "GET index" do
    it "requests activation keys using search criteria" do
      ActivationKey.should_receive(:search_for) {ActivationKey}
      ActivationKey.stub_chain(:where, :limit)
      get :index
    end

    it "attempts to retain request in search history" do
      controller.should_receive(:retain_search_history)
      get :index
    end

    it "returns activation keys" do
      get :index
      assigns[:activation_keys].should include ActivationKey.find(@a_key.id)
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
        controller.should_receive(:errors)
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
        controller.should_receive(:errors)
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
        post :create, AKeyControllerTest::AKEY
        assigns[:activation_key].name.should eq(AKeyControllerTest::AKEY[:activation_key_name]) 
        assigns[:activation_key].description.should eq(AKeyControllerTest::AKEY[:activation_key_description])
      end

      it "renders list item partial for 2 pane" do
        post :create, AKeyControllerTest::AKEY
        response.should render_template(:partial => "common/_list_item")
      end

      it "should generate a success notice" do
        controller.should_receive(:notice)
        post :create, AKeyControllerTest::AKEY
      end

      it "should be successful" do
        post :create, AKeyControllerTest::AKEY
        response.should be_success
      end
    end

    describe "with invalid params" do
      it "should generate an error notice" do
        controller.should_receive(:errors)
        post :create, AKeyControllerTest::AKEY_INVALID
      end

      it "should be unsuccessful" do
        post :create, AKeyControllerTest::AKEY_INVALID
        response.should_not be_success
      end
    end
  end

  describe "PUT update" do
    describe "with valid activation key id" do
      describe "with valid params" do
        it "should update requested field" do
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
          assigns[:activation_key].description.should eq(AKeyControllerTest::AKEY_DESCRIPTION[:description])
        end

        it "should generate a success notice" do
          controller.should_receive(:notice)
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
        end

        it "should not redirect from edit view" do
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
          response.should_not redirect_to()
        end

        it "should be successful" do
          put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
          response.should be_success
       end
      end

      describe "with invalid params" do
        it "should generate an error notice" do
          controller.should_receive(:errors)
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
        controller.should_receive(:errors)
        put :update, :id => 9999, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
      end

      it "should be unsuccessful" do
        put :update, :id => 9999, :activation_key => AKeyControllerTest::AKEY_DESCRIPTION
        response.should_not be_success
      end

      it "should be unsuccessful subscription update" do
        controller.should_receive(:errors)
        put :update_subscriptions, { :id => 999, :activation_key => { :consumed_sub_ids => ["abc123"] }}
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
        controller.should_receive(:errors)
        delete :destroy, :id => 9999
      end

      it "should be unsuccessful" do
        delete :destroy, :id => 9999
        response.should_not be_success
      end
    end
  end
end
