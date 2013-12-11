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
  describe OrganizationsController do

    include LocaleHelperMethods
    include OrganizationHelperMethods
    include AuthorizationHelperMethods

    module OrgControllerTest
      ORG_ID = 1
      ORGANIZATION = {:organization => {:name => "organization_name", :label => "organization_name",:description => "organization_description"},
                      :environment => {:description=>"foo", :label => "foo",:name => "organization_env"}}
      ORGANIZATION_UPDATE = {:description => "organization_description"}
    end

    before (:each) do
      setup_controller_defaults
      @controller.stubs(:search_validate).returns(true)
    end

    describe "rules" do
      before (:each) do
        @org1 = new_test_org
        @organization = new_test_org
      end
      describe "GET index" do
        let(:action) {:items}
        let(:req) { get :items }
        let(:authorized_user) do
          user_with_permissions { |u| u.can(:read, :organizations,nil, @organization) }
        end
        let(:unauthorized_user) do
          user_without_permissions
        end

        it_should_behave_like "protected action"
      end

      describe "update org put" do
        before do
          @organization.stubs(:update_attributes!).returns(OrgControllerTest::ORGANIZATION[:organization])
          @organization.stubs(:name).returns(OrgControllerTest::ORGANIZATION[:organization][:name])
          Organization.stubs(:find_by_label).returns(@organization)
        end
        let(:action) {:update}
        let(:req) do
          put 'update', :id => @organization.id, :organization => OrgControllerTest::ORGANIZATION_UPDATE
        end
        let(:authorized_user) do
          user_with_permissions { |u| u.can(:update, :organizations,nil, @organization) }
        end
        let(:unauthorized_user) do
          user_without_permissions
        end
        it_should_behave_like "protected action"
      end
    end

    describe "create a root org" do
      describe 'with valid parameters' do
        before (:each) do
          # for these tests we need full user

          @organization = new_test_org #controller.current_organization
          @controller.stubs(:current_organization).returns(@organization)
        end

        it 'should create organization (katello)' do #TODO headpin
          post 'create', OrgControllerTest::ORGANIZATION
          must_respond_with(:success)
          assigns[:organization].name.must_equal OrgControllerTest::ORGANIZATION[:organization][:name]
        end

        it 'should create organization and account for spaces (katello)' do #TODO headpin
          post 'create', {:organization => {:name => "multi word organization",:label=> "multi-word-organization",
                                            :description => "spaced out organization"}, :environment => {:name => "first-env", :label => "first-env"}}
          must_respond_with(:success)
          assigns[:organization].name.must_equal "multi word organization"
          assigns[:organization].label.must_equal "multi-word-organization"
        end

        it 'should generate a success notice' do
          must_notify_with(:success)
          post 'create', OrgControllerTest::ORGANIZATION
          must_respond_with(:success)
        end
      end

      describe 'with invalid paramaters' do
        it 'should generate an error notice' do
          must_notify_with(:error)
          post 'create', { :name => "", :description => "" }
          response.must_respond_with(400)
        end

        it 'should generate an error notice for a bad label' do
          must_notify_with(:exception)
          post 'create', {:organization => { :name => "ACME", :label => "bad\n<label>" }}
          response.must_respond_with(422)
        end

        let(:req) do
          bad_req           = { :organization => { :name    => "multi word organization", :description => "spaced out organization",
                                                   :envname => "first-env" } }
          bad_req[:bad_foo] = "mwahaha"
          post :create, bad_req
        end

        it_should_behave_like "bad request"
      end

    end

    describe "get a listing of organizations" do
      before (:each) do
        new_test_org
      end

      it 'should call katello organization find api' do
        get :index
        must_respond_with(:success)
        must_render_template("index")
      end

      it 'should allow for an offset' do
        @controller.stubs(:render)
        @controller.expects(:render_panel_direct)
        get 'items', :offset=> "5"
        must_respond_with(:success)
      end
    end

    describe "delete an organization" do

      describe "with no exceptions thrown" do
        before (:each) do
          @controller.stubs(:render).returns("") #fix for not finding partial
          @org = new_test_org
          @org.stubs(:name).returns(OrgControllerTest::ORGANIZATION[:name])
          Organization.stubs(:find_by_label).returns(@org)
          new_test_org
        end

        it 'should call katello organization destroy api if there are more than 1 organizations (katello)' do #TODO headpin
          Organization.stubs(:count).returns(2)
          OrganizationDestroyer.expects(:destroy).with(@org, :notify => true).once.returns(true)
          delete 'destroy', :id => @org.id
          must_respond_with(:success)
        end

        it "should generate a success notice" do
          Organization.stubs(:count).returns(2)
          OrganizationDestroyer.expects(:destroy).with(@org, :notify => true).once.returns(true)
          must_notify_with(:success)
          delete 'destroy', :id => @org.id
          must_respond_with(:success)
        end

        it "should be successful (katello)" do #TODO headpin
          Organization.stubs(:count).returns(2)
          delete 'destroy', :id => @org.id
          must_respond_with(:success)
        end
      end

      describe "with exceptions thrown" do
        before (:each) do
          new_test_org
          Organization.stubs(:find_by_label).returns(@organization)
        end
        it "should generate an errors notice" do
          must_notify_with(:error)
          delete 'destroy', :id => @organization.id
          response.must_respond_with(400)
        end
      end

      describe "exception is thrown in katello api" do
        before (:each) do
          @organization = new_test_org
          @organization.stubs(:destroy).raises(StandardError)
          Organization.stubs(:find_by_label).returns(@organization)
        end

        it "should generate an error notice" do
          must_notify_with(:error)
          delete 'destroy', :id =>  OrgControllerTest::ORG_ID
          response.must_respond_with(400)
        end

        it "should redirect to show view (katello)" do #TODO headpin
          delete 'destroy', :id =>  OrgControllerTest::ORG_ID
          response.must_respond_with(400)
        end
      end
    end

    describe "update a organization" do

      describe "with no exceptions thrown" do

        before (:each) do
          @organization = new_test_org
          @organization.stubs(:save!).returns(true)
          @organization.stubs(:update_attributes!).returns(OrgControllerTest::ORGANIZATION[:organization])
          @organization.stubs(:name).returns(OrgControllerTest::ORGANIZATION[:organization][:name])
          Organization.stubs(:find_by_label).returns(@organization)
        end

        it "should call katello org update api (katello)" do #TODO headpin
          @organization.expects(:save!).once
          put 'update', :id => OrgControllerTest::ORG_ID, :organization => OrgControllerTest::ORGANIZATION_UPDATE
          must_respond_with(:success)
        end

        it "should generate a success notice" do
          must_notify_with(:success)
          put 'update', :id => OrgControllerTest::ORG_ID, :organization => OrgControllerTest::ORGANIZATION_UPDATE
        end

        it "should not redirect from edit view (katello)" do #TODO headpin
          put 'update', :id => OrgControllerTest::ORG_ID, :organization => OrgControllerTest::ORGANIZATION_UPDATE
          response.must_respond_with(:success)
        end
      end
      describe "with invalid params" do
        before do
          @organization = new_test_org
        end

        let(:req) do
          bad_req = {:id => @organization.label, :organization => {:desc =>"grand" }}
          put :update, bad_req
        end

        it_should_behave_like "bad request"
      end

      describe "exception is thrown in katello api" do
        before(:each) do
          @organization = new_test_org
          @organization.stubs(:update).raises(StandardError)
          Organization.stubs(:find_by_label).returns(@organization)
        end

        it "should generate an error notice" do
          must_notify_with(:error)
          put 'update', :id => OrgControllerTest::ORG_ID
        end

        it "should not redirect from edit view (katello)" do #TODO headpin
          put 'update', :id => OrgControllerTest::ORG_ID
          must_respond_with(400)
        end
      end
    end

    describe "Debug Certificates related test" do
      before (:each) do
        new_test_org
      end
      it "should download" do
        Resources::Candlepin::Owner.expects(:get_ueber_cert).once.returns(:cert => "uber",:key=>"ueber")
        get :download_debug_certificate, :id => @organization.id.to_s
        must_respond_with(:success)
      end

    end

    describe "default_info" do

      before(:each) do
        @organization = new_test_org
        Organization.stubs(:find_by_label).returns(@organization)
      end

      it "should render template" do
        get :default_info, :id => @organization.id.to_s, :informable_type => "system"
        must_respond_with(:success)
        must_render_template("default_info")
      end

    end
  end
end
