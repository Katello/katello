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

describe GpgKeysController do

  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods


  module GPGKeyControllerTest
    GPGKEY_INVALID = {}
    GPGKEY_NAME_INVALID = {:name => ""}
    GPGKEY_NAME = {:name => "Test GPG Key Updated"}
  end

  before(:each) do
    set_default_locale
    login_user

    @organization = new_test_org
    @gpg_key = GpgKey.create!( :name => "Another Test Key", :organization => @organization )
    @gpg_key_params = { :gpg_key => { :name => "Test Key", :organization_id => @organization.id } }
  end

  describe "rules" do
    let(:action) {:items }
    let(:req) { get :items }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:read_all, :gpg_keys) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"
  end

  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template(:index)
    end

    it "should be successful" do
      get :index
      response.should be_success
    end
  end

  describe "GET show" do
    describe "with valid GPG Key id" do
      it "renders a list update partial for 2pane" do
        get :show, :id => @gpg_key.id
        response.should render_template(:partial => "common/_list_update")
      end

      it "should be successful" do
        get :show, :id => @gpg_key.id
        response.should be_success
      end
    end

    describe "with invalid GPG Key id" do
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
    it "renders a new partial for 2pane" do
      get :new
      response.should render_template(:partial => "new")
    end

    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "GET edit" do
    describe "with valid GPG Key id" do
      it "renders an edit partial for 2pane" do
        get :edit, :id => @gpg_key.id
        response.should render_template(:partial => "edit")
      end

      it "should be successful" do
        get :edit, :id => @gpg_key.id
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
      it "should be successful" do
        post :create, @gpg_key_params
        response.should be_success
      end
      
      it "assigns a newly created GPG Key" do
        post :create, @gpg_key_params
        assigns[:gpg_key].name.should eq(@akey_params[:activation_key][:name])
        assigns[:gpg_key].organization_id.should eq(@gpg_key_params[:gpg_key][:organization_id])
      end

      it "renders list item partial for 2 pane" do
        post :create, @gpg_key_params
        response.should render_template(:partial => "common/_list_item")
      end
      
      it "should generate a success notice" do
        controller.should_receive(:notice)
        post :create, @gpg_key_params
      end
    end

    describe "with invalid params" do
      it "should generate an error notice" do
        controller.should_receive(:errors)
        post :create, GPGKeyControllerTest::GPGKEY_INVALID
      end

      it "should be unsuccessful" do
        post :create, GPGKeyControllerTest::GPGKEY_INVALID
        response.should_not be_success
      end
    end
    
    describe "with inclusive search parameters" do
      it "should render list item partial for 2pane" do
        @gpg_key_params[:search] = { :name => 'Test' }
        post :create, @gpg_key_params
        response.should render_template(:partial => "common/_list_item")
      end
    end
    
    describe "with exclusive search parameters" do
      it "should return no match indicator" do
        @gpg_key_params[:search] = { :name => 'Fake' }
        post :create, @gpg_key_params
        response.body.should eq({ :no_match => true })
      end
      
      it "should generate message notice" do
        controller.should_receive(:message)
        put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME, :search => { :name => 'Fake' }
      end
    end
  end

  describe "PUT update" do

    describe "authorization rules should behave like" do
      let(:action) { :update }
      let(:req) { put :update, :id => @a_key.id, :activation_key => AKeyControllerTest::AKEY_NAME }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:manage_all, :activation_keys) }
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read_all, :activation_keys) }
      end
      it_should_behave_like "protected action"
    end

    describe "with valid GPG Key ID" do
      describe "with valid params" do
        it "should update requested field - name" do
          put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
          assigns[:gpg_key].name.should eq(GPGKeyControllerTest::GPGKEY_NAME[:name])
        end

        it "should generate a success notice" do
          controller.should_receive(:notice)
          put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
        end

        it "should not redirect from edit view" do
          put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
          response.should_not be_redirect
        end

        it "should be successful" do
          put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
          response.should be_success
        end

      end

      describe "with invalid params" do
        it "should generate an error notice" do
          controller.should_receive(:errors)
          put :update, :id => @gpg_key.id, :activation_key => GPGKeyControllerTest::GPGKEY_NAME_INVALID
        end

        it "should be unsuccessful" do
          put :update, :id => @gpg_key.id, :activation_key => GPGKeyControllerTest::GPGKEY_NAME_INVALID
          response.should_not be_success
        end
      end
    end

    describe "with invalid GPG Key ID" do
      it "should generate an error notice" do
        controller.should_receive(:errors)
        put :update, :id => 9999, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
      end

      it "should be unsuccessful" do
        put :update, :id => 9999, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
        response.should_not be_success
      end
    end
    
    describe "with inclusive search parameters" do
      it "should render list item partial for 2pane" do
        put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME, :search => { :name => 'Test' }
        response.should render_template(:partial => "common/_list_item")
      end
    end
    
    describe "with exclusive search parameters" do
      it "should return no match indicator" do
        put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME, :search => { :name => 'Fake' }
        response.body.should eq({ :no_match => true })
      end
      
      it "should generate message notice" do
        controller.should_receive(:message)
        put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME, :search => { :name => 'Fake' }
      end
    end
  end

  describe "DELETE destroy" do
    describe "with valid GPG Key id" do
      before (:each) do
        controller.stub!(:render).and_return("") #ignore missing list_remove js partial
      end

      it "should delete the GPG Key" do
        delete :destroy, :id => @gpg_key.id
        GpgKey.exists?(@gpg_key.id).should be_false
      end

      it "should generate a success notice" do
        controller.should_receive(:notice)
        delete :destroy, :id => @gpg_key.id
      end

      it "should be successful" do
        delete :destroy, :id => @gpg_key.id
        response.should be_success
      end
    end

    describe "with invalid GPG Key id" do
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