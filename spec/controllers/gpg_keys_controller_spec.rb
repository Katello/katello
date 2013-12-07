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
  describe GpgKeysController do

    include LocaleHelperMethods
    include OrganizationHelperMethods
    include AuthorizationHelperMethods

    module GPGKeyControllerTest
      GPGKEY_INVALID        = {}
      GPGKEY_NAME_INVALID   = { :name => "" }
      GPGKEY_NAME           = { :name => "Test GPG Key Updated" }
      GPGKEY_CONTENT        = { :content => File.open("#{Katello::Engine.root}/spec/assets/gpg_test_key").read + "\n" }
      GPGKEY_CONTENT_UPLOAD = {}
    end

    describe "(katello)" do

      before(:each) do
        setup_controller_defaults
        @controller.stubs(:validate_search).returns(true)
        test_document = "#{Katello::Engine.root}/spec/assets/gpg_test_key"
        @file         = Rack::Test::UploadedFile.new(test_document, "text/plain")

        @organization            = new_test_org
        test_gpg_content         = GPGKeyControllerTest::GPGKEY_CONTENT[:content]
        @gpg_key                 = GpgKey.create!(:name => "Another Test Key", :content => test_gpg_content, :organization => @organization)
        @gpg_key_params_pasted   = { :gpg_key => { :name => "Test Key", :content => test_gpg_content } }
        @gpg_key_params_uploaded = { :gpg_key => { :name => "Test Key", :content_upload => @file } }
      end

      describe "rules" do
        let(:action) { :items }
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
          must_render_template(:index)
        end

        it "should be successful" do
          get :index
          must_respond_with(:success)
        end
      end

      describe "GET show" do
        describe "with valid GPG Key id" do
          it "renders a list update partial for 2pane" do
            get :show, :id => @gpg_key.id
            must_render_template(:partial => "katello/common/_list_update")
          end

          it "should be successful" do
            get :show, :id => @gpg_key.id
            must_respond_with(:success)
          end
        end

        describe "with invalid GPG Key id" do
          it "should generate an error notice" do
            must_notify_with(:error)
            get :show, :id => 9999
          end

          it "should be unsuccessful" do
            get :show, :id => 9999
            response.must_respond_with(404)
          end
        end
      end

      describe "GET new" do
        it "renders a new partial for 2pane" do
          get :new
          must_render_template(:partial => "_new")
        end

        it "should be successful" do
          get :new
          must_respond_with(:success)
        end
      end

      describe "GET edit" do
        describe "with valid GPG Key id" do
          it "renders an edit partial for 2pane" do
            get :edit, :id => @gpg_key.id
            must_render_template(:partial => "_edit")
          end

          it "should be successful" do
            get :edit, :id => @gpg_key.id
            must_respond_with(:success)
          end
        end

        describe "with invalid activation key id" do
          it "should generate an error notice" do
            must_notify_with(:error)
            get :edit, :id => 9999
          end

          it "should be unsuccessful" do
            get :edit, :id => 9999
            response.must_respond_with(404)
          end
        end
      end

      describe "POST create" do
        before :each do
          @controller.stubs(:search_validate).returns(true)
        end

        describe "with valid params" do
          describe "that include a copy/pasted GPG Key" do
            it "should be successful" do
              post :create, @gpg_key_params_pasted
              must_respond_with(:success)
            end

            it "assigns a newly created GPG Key" do
              post :create, @gpg_key_params_pasted
              assigns[:gpg_key].name.must_equal(@gpg_key_params_pasted[:gpg_key][:name])
              assigns[:gpg_key].content.must_equal(@gpg_key_params_pasted[:gpg_key][:content])
            end

            it "renders list item partial for 2 pane" do
              post :create, @gpg_key_params_pasted
              must_render_template(:partial => "katello/common/_list_item")
            end

            it "should generate a success notice" do
              must_notify_with(:success)
              post :create, @gpg_key_params_pasted
            end
          end

          describe "that include an uploaded GPG Key file" do
            it "should be successful" do
              post :create, @gpg_key_params_uploaded
              must_respond_with(:success)
            end

            it "assigns a newly created GPG Key" do
              post :create, @gpg_key_params_uploaded
              assigns[:gpg_key].name.must_equal(@gpg_key_params_uploaded[:gpg_key][:name])
              assigns[:gpg_key].content.must_equal(GPGKeyControllerTest::GPGKEY_CONTENT[:content])
            end

            it "renders list item partial for 2 pane" do
              post :create, @gpg_key_params_uploaded
              must_render_template(:partial => "katello/common/_list_item")
            end

            it "should generate a success notice" do
              must_notify_with(:success)
              post :create, @gpg_key_params_uploaded
            end
          end
        end

        describe "with invalid params" do
          it "should generate an error notice" do
            must_notify_with(:error)
            post :create, GPGKeyControllerTest::GPGKEY_INVALID
          end

          it "should be unsuccessful" do
            post :create, GPGKeyControllerTest::GPGKEY_INVALID
            must_respond_with(400)
          end

          let(:req) do
            bad_req                     = @gpg_key_params_pasted
            bad_req[:gpg_key][:bad_foo] = "mwahaha"
            post :create, bad_req
          end

          it_should_behave_like "bad request"
        end

        describe "with inclusive search parameters" do
          it "should render list item partial for 2pane" do
            @gpg_key_params_pasted[:search] = 'name ~ Test'
            post :create, @gpg_key_params_pasted
            must_render_template(:partial => "katello/common/_list_item")
          end
        end

        describe "with exclusive search parameters" do
          before :each do
            @controller.stubs(:search_validate).returns(false)
          end

          it "should return no match indicator" do
            @gpg_key_params_pasted[:search] = 'name ~ Fake'
            post :create, @gpg_key_params_pasted
            response.body.must_equal("{\"no_match\":true}")
          end

          it "should generate message notice" do
            @gpg_key_params_pasted[:search] = 'name ~ Fake'
            must_notify_with(:success)
            post :create, @gpg_key_params_pasted
          end
        end
      end

      describe "GET products and repos" do

        it "should be successful" do
          get :products_repos, :id => @gpg_key.id
          must_respond_with(:success)
        end

      end

      describe "PUT update" do
        before :each do
          @controller.stubs(:search_validate).returns(true)
        end

        describe "authorization rules should behave like" do
          let(:action) { :update }
          let(:req) { put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME }
          let(:authorized_user) do
            user_with_permissions { |u| u.can(:gpg, :organizations, nil, @organization) }
          end
          let(:unauthorized_user) do
            user_with_permissions { |u| u.can(:read, :organizations, nil, @organization) }
          end
          it_should_behave_like "protected action"
        end

        describe "with valid GPG Key ID" do
          describe "with valid params" do
            it "should update requested field - name" do
              put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
              assigns[:gpg_key].name.must_equal(GPGKeyControllerTest::GPGKEY_NAME[:name])
            end

            it "should generate a success notice" do
              must_notify_with(:success)
              put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
            end

            it "should not redirect from edit view" do
              put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
              response.must_respond_with(:success)
            end

            it "should be successful" do
              put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
              must_respond_with(:success)
            end

            describe "that include a copy/pasted GPG Key" do
              before do
                @gpg_key_content = { :content => File.read("#{Katello::Engine.root}/spec/assets/gpg_test_key") }
              end
              it "should update requested field - content" do
                put :update, :id => @gpg_key.id, :gpg_key => @gpg_key_content
                assigns[:gpg_key].content.must_equal(@gpg_key_content[:content])
              end

              it "should generate a success notice" do
                must_notify_with(:success)
                put :update, :id => @gpg_key.id, :gpg_key => @gpg_key_content
              end

              it "should be successful" do
                put :update, :id => @gpg_key.id, :gpg_key => @gpg_key_content
                must_respond_with(:success)
              end
            end

            describe "that include an uploaded GPG Key file" do
              before(:each) do
                @gpg_key_content_upload = { :content_upload => @file }
              end

              it "should update requested field - content_upload" do
                put :update, :id => @gpg_key.id, :gpg_key => @gpg_key_content_upload
                gpg_key_content = GPGKeyControllerTest::GPGKEY_CONTENT[:content]
                assigns[:gpg_key].content.must_equal(gpg_key_content)
              end

              it "should generate a success notice" do
                must_notify_with(:success)
                put :update, :id => @gpg_key.id, :gpg_key => @gpg_key_content_upload
              end

              it "should not redirect from edit view" do
                put :update, :id => @gpg_key.id, :gpg_key => @gpg_key_content_upload
                response.must_respond_with(:success)
              end

              it "should be successful" do
                put :update, :id => @gpg_key.id, :gpg_key => @gpg_key_content_upload
                must_respond_with(:success)
              end
            end
          end

          describe "with invalid params" do
            it "should generate an error notice" do
              put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME_INVALID
              # checking for bad response since we're not notifying in order to
              # handle iframe
              response.code.to_s.must_match /^4/
            end

            it "should be unsuccessful" do
              put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME_INVALID
              must_respond_with(400)
            end

            let(:req) do
              bad_req                     = { :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_CONTENT }
              bad_req[:gpg_key][:bad_foo] = "mwahaha"
              put :update, bad_req
            end

            it_should_behave_like "bad request"
          end
        end

        describe "with invalid GPG Key ID" do
          it "should generate an error notice" do
            must_notify_with(:error)
            put :update, :id => 9999, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
          end

          it "should be unsuccessful" do
            put :update, :id => 9999, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME
            must_respond_with(404)
          end
        end

        describe "with inclusive search parameters" do
          it "should generate a single notice" do
            must_notify_with(:success)
            put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME, :search => 'name ~ Test'
          end
        end

        describe "with exclusive search parameters" do
          it "should generate message notice" do
            @controller.stubs(:search_validate).returns(false)
            must_notify_with(:success)
            put :update, :id => @gpg_key.id, :gpg_key => GPGKeyControllerTest::GPGKEY_NAME, :search => 'name ~ Fake'
          end
        end
      end

      describe "DELETE destroy" do
        describe "with valid GPG Key id" do
          before (:each) do
            @controller.stubs(:render).returns("") #ignore missing list_remove js partial
          end

          it "should delete the GPG Key" do
            delete :destroy, :id => @gpg_key.id
            GpgKey.exists?(@gpg_key.id).must_equal(false)
          end

          it "should generate a success notice" do
            must_notify_with(:success)
            delete :destroy, :id => @gpg_key.id
          end

          it "should be successful" do
            delete :destroy, :id => @gpg_key.id
            must_respond_with(:success)
          end
        end

        describe "with invalid GPG Key id" do
          it "should generate an error notice" do
            must_notify_with(:error)
            delete :destroy, :id => 9999
          end

          it "should be unsuccessful" do
            delete :destroy, :id => 9999
            response.must_respond_with(404)
          end
        end
      end
    end

  end
end
