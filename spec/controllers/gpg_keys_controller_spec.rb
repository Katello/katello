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

require 'spec_helper'

describe GpgKeysController, :katello => true do

  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  module GPGKeyControllerTest
    GPGKEY_INVALID = {}
    GPGKEY_NAME_INVALID = {:name => ""}
    GPGKEY_NAME = {:name => "Test GPG Key Updated"}
    GPGKEY_CONTENT = {:content => "Test GPG Key Updated key contents."}
    GPGKEY_CONTENT_UPLOAD = {}
  end

  before(:each) do
    set_default_locale
    login_user({:mock => false})
    controller.stub(:validate_search).and_return(true)
    test_document = "#{Rails.root}/spec/assets/gpg_test_key"
    @file = Rack::Test::UploadedFile.new(test_document, "text/plain")

    @organization = new_test_org
    @gpg_key = GpgKey.create!(:name => "Another Test Key", :content => "This is the key data string", :organization => @organization)
    @gpg_key_params_pasted = { :gpg_key => { :name => "Test Key", :content => "This is the pasted key data string" } }
    @gpg_key_params_uploaded = { :gpg_key => { :name => "Test Key", :content_upload => @file } }
  end

  describe "rules" do
    let(:action) {:items }
    let(:req) { get :items }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:gpg, :organizations, nil, @organization) }
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
        controller.should notify.error
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
      response.should render_template(:partial => "_new")
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
        response.should render_template(:partial => "_edit")
      end

      it "should be successful" do
        get :edit, :id => @gpg_key.id
        response.should be_success
      end
    end

    describe "with invalid activation key id" do
      it "should generate an error notice" do
        controller.should notify.error
        get :edit, :id => 9999
      end

      it "should be unsuccessful" do
        get :edit, :id => 9999
        response.should_not be_success
      end
    end
  end

  describe "POST create" do
    before :each do
      controller.stub(:search_validate).and_return(true)
    end

    describe "with valid params" do
      describe "that include a copy/pasted GPG Key" do
        it "should be successful" do
          post :create, @gpg_key_params_pasted
          response.should be_success
        end

        it "assigns a newly created GPG Key" do
          post :create, @gpg_key_params_pasted
          assigns[:gpg_key].name.should eq(@gpg_key_params_pasted[:gpg_key][:name])
          assigns[:gpg_key].content.should eq(@gpg_key_params_pasted[:gpg_key][:content])
        end

        it "renders list item partial for 2 pane" do
          post :create, @gpg_key_params_pasted
          response.should render_template(:partial => "common/_list_item")
        end

        it "should generate a success notice" do
          controller.should notify.success
          post :create, @gpg_key_params_pasted
        end
      end

      describe "that include an uploaded GPG Key file" do
        it "should be successful" do
          post :create, @gpg_key_params_uploaded
          response.should be_success
        end

        it "assigns a newly created GPG Key" do
          test_document = "#{Rails.root}/spec/assets/gpg_test_key"
          temp_file = Rack::Test::UploadedFile.new(test_document, "text/plain")
          post :create, @gpg_key_params_uploaded
          assigns[:gpg_key].name.should eq(@gpg_key_params_uploaded[:gpg_key][:name])
          assigns[:gpg_key].content.should eq(temp_file.read)
        end

        it "renders list item partial for 2 pane" do
          post :create, @gpg_key_params_uploaded
          response.should render_template(:partial => "common/_list_item")
        end

        it "should generate a success notice" do
          controller.should notify.success
          post :create, @gpg_key_params_uploaded
        end
      end
    end

    describe "with invalid params" do
      it "should generate an error notice" do
        controller.should notify.error
        post :create, GPGKeyControllerTest::GPGKEY_INVALID
      end

      it "should be unsuccessful" do
        post :create, GPGKeyControllerTest::GPGKEY_INVALID
        response.should_not be_success
      end

      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = @gpg_key_params_pasted
          bad_req[:gpg_key][:bad_foo] = "mwahaha"
          post :create, bad_req
        end
      end
    end

    describe "with inclusive search parameters" do
      it "should render list item partial for 2pane" do
        @gpg_key_params_pasted[:search] = 'name ~ Test'
        post :create, @gpg_key_params_pasted
        response.should render_template(:partial => "common/_list_item")
      end
    end

    describe "with exclusive search parameters" do
      before :each do
        controller.stub(:search_validate).and_return(false)
      end

      it "should return no match indicator" do
        @gpg_key_params_pasted[:search] = 'name ~ Fake'
        post :create, @gpg_key_params_pasted
        response.body.should eq("{\"no_match\":true}")
      end

      it "should generate message notice" do
        @gpg_key_params_pasted[:search] = 'name ~ Fake'
        controller.should notify(:success, :message)
        post :create, @gpg_key_params_pasted
      end
    end
  end

  describe "PUT update" do
    before :each do
      controller.stub(:search_validate).and_return(true)
    end

    describe "authorization rules should behave like" do
      let(:action) { :update }
      let(:req) { put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:gpg, :organizations, nil, @organization)}
      end
      let(:unauthorized_user) do
        user_with_permissions { |u| u.can(:read, :organizations, nil, @organization)}
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
          controller.should notify.success
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

        describe "that include a copy/pasted GPG Key" do
          it "should update requested field - content" do
            put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_CONTENT
            assigns[:gpg_key].content.should eq(GPGKeyControllerTest::GPGKEY_CONTENT[:content])
          end

          it "should generate a success notice" do
            controller.should notify.success
            put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_CONTENT
          end

          it "should not redirect from edit view" do
            put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_CONTENT
            response.should_not be_redirect
          end

          it "should be successful" do
            put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_CONTENT
            response.should be_success
          end
        end

        describe "that include an uploaded GPG Key file" do
          before(:each) do
            test_document = "#{Rails.root}/spec/assets/gpg_test_key"
            @gpg_key_file = Rack::Test::UploadedFile.new(test_document, "text/plain")

            @GPGKEY_CONTENT_UPLOAD = { :content_upload => @gpg_key_file }
          end

          it "should update requested field - content_upload" do
            put :update, :id => @gpg_key.id, :gpg_key => @GPGKEY_CONTENT_UPLOAD
            gpg_key_content = @gpg_key_file.open.read
            @gpg_key_file.close
            assigns[:gpg_key].content.should eq(gpg_key_content)
          end

          it "should generate a success notice" do
            controller.should notify.success
            put :update, :id => @gpg_key.id, :gpg_key => @GPGKEY_CONTENT_UPLOAD
          end

          it "should not redirect from edit view" do
            put :update, :id => @gpg_key.id, :gpg_key => @GPGKEY_CONTENT_UPLOAD
            response.should_not be_redirect
          end

          it "should be successful" do
            put :update, :id => @gpg_key.id, :gpg_key => @GPGKEY_CONTENT_UPLOAD
            response.should be_success
          end
        end
      end

      describe "with invalid params" do
        it "should generate an error notice" do
          put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME_INVALID
          # checking for bad response since we're not notifying in order to
          # handle iframe
          response.code.to_s.should match /^4/
        end

        it "should be unsuccessful" do
          put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME_INVALID
          response.should_not be_success
        end

        it_should_behave_like "bad request"  do
          let(:req) do
            bad_req = {:id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_CONTENT}
            bad_req[:gpg_key][:bad_foo] = "mwahaha"
            put :update, bad_req
          end
        end
      end
    end

    describe "with invalid GPG Key ID" do
      it "should generate an error notice" do
        controller.should notify.error
        put :update, :id => 9999, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
      end

      it "should be unsuccessful" do
        put :update, :id => 9999, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
        response.should_not be_success
      end
    end

    describe "with inclusive search parameters" do
      it "should generate a single notice" do
        controller.should notify.success
        put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME, :search => 'name ~ Test'
      end
    end

    describe "with exclusive search parameters" do
      it "should generate message notice" do
        controller.stub(:search_validate).and_return(false)
        controller.should notify(:success, :message)
        put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME, :search => 'name ~ Fake'
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
        controller.should notify.success
        delete :destroy, :id => @gpg_key.id
      end

      it "should be successful" do
        delete :destroy, :id => @gpg_key.id
        response.should be_success
      end
    end

    describe "with invalid GPG Key id" do
      it "should generate an error notice" do
        controller.should notify.error
        delete :destroy, :id => 9999
      end

      it "should be unsuccessful" do
        delete :destroy, :id => 9999
        response.should_not be_success
      end
    end
  end

end
