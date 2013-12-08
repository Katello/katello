## Copyright 2013 Red Hat, Inc.
##
## This software is licensed to you under the GNU General Public
## License as published by the Free Software Foundation; either version
## 2 of the License (GPLv2) or (at your option) any later version.
## There is NO WARRANTY for this software, express or implied,
## including the implied warranties of MERCHANTABILITY,
## NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
## have received a copy of GPLv2 along with this software; if not, see
## http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
  describe Api::V1::GpgKeysController do
    describe "(katello)" do
      include OrganizationHelperMethods
      include AuthorizationHelperMethods

      let(:authorized_user) { user_with_permissions { |u| u.can(:gpg, :organizations, nil, @organization) } }
      let(:unauthorized_user) { user_without_permissions }

      before(:each) do
        setup_controller_defaults_api
        @request.env["HTTP_ACCEPT"] = "application/json"
        disable_org_orchestration

        @organization     = new_test_org
        @test_gpg_content = File.open("#{Katello::Engine.root}/spec/assets/gpg_test_key").read
        @gpg_key          = GpgKey.create!(:name => "Another Test Key", :content => @test_gpg_content, :organization => @organization)
      end

      describe "GET content" do
        describe "with valid GPG Key id" do

          it "should be successful" do
            get :content, :id => @gpg_key.id
            response.body.must_equal @gpg_key.content
          end
        end

        describe "with invalid GPG Key id" do
          it "should be unsuccessful" do
            get :content, :id => 9999
            response.response_code.must_equal 404
          end
        end
      end

      describe "list gpg keys" do
        let(:req_params) { { :organization_id => @organization.name, :name => @gpg_key.name }.with_indifferent_access }
        let(:req) { get :index, req_params }
        let(:action) { :index }
        it_should_behave_like "protected action"

        it "return list of found keys in JSON" do
          req
          response.body == [@gpg_key.to_json(:only => [:id, :name])]
        end
      end

      describe "show gpg key" do
        let(:req_params) { { :id => @gpg_key.id }.with_indifferent_access }
        let(:req) { get :show, req_params }
        let(:action) { :show }
        it_should_behave_like "protected action"

        it "return list of found keys in JSON" do
          req
          response.body == @gpg_key.to_json
        end

        it "must_include assigned repos and products" do
          req
          resp_json = JSON.parse(response.body)
          resp_json.must_include("repositories", "products")
          resp_json["products"].must_be_empty
          resp_json["repositories"].must_be_empty
        end
      end

      describe "create gpg key" do
        describe "good request" do
          let(:req) { post :create, req_params }
          let(:action) { :create }
          let(:req_params) do
            { :organization_id => @organization.name, :gpg_key => { :name => "Gpg Key", :content => @test_gpg_content } }.with_indifferent_access
          end
          it_should_behave_like "protected action"

          it "returns JSON with created key" do
            req
            JSON.parse(response.body).slice(*%w[name content]).must_equal req_params[:gpg_key]
          end
        end

        describe "test invalid params" do
          let(:req) do
            bad_req = { :organization_id => @organization.name,
                        :gpg_key         =>
                            { :bad_foo => "mwahahaha",
                              :name    => "Gpg Key",
                              :content => "This is the key string" }
            }.with_indifferent_access
            post :create, bad_req
          end
          it_should_behave_like "bad request"
        end
      end

      describe "update gpg key" do
        let(:req_params) { { :id => @gpg_key.id.to_s, :gpg_key => { :name => "Gpg Key", :content => @test_gpg_content } }.with_indifferent_access }
        let(:req) { put :update, req_params }
        let(:action) { :update }
        it_should_behave_like "protected action"

        it "returns JSON with updated key" do
          GpgKey.stubs(:find).with(@gpg_key.id.to_s).returns(@gpg_key)
          req
          JSON.parse(response.body).slice(*%w[name content]).must_equal req_params[:gpg_key]
        end
      end

      describe "destroy gpg key" do
        let(:req_params) { { :id => @gpg_key.id }.with_indifferent_access }
        let(:req) { delete :destroy, req_params }
        let(:action) { :destroy }
        it_should_behave_like "protected action"

        it "remove the record" do
          req
          GpgKey.where(:id => @gpg_key.id).must_be_empty
        end
      end
    end
  end
end
