#
# Copyright 2014 Red Hat, Inc.
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
require 'ostruct'

module Katello
describe EnvironmentsController do
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  module EnvControllerTest
    ENV_NAME = "environment_name"
    NEW_ENV_NAME = "another_environment_name"

    ENVIRONMENT = {:id => 2, :name => ENV_NAME, :description => nil, :prior => nil, :path => []}
    LIBRARY = {:id => 1, :name => 'Library', :description => nil, :prior => nil, :path => [],
               :display_name => 'Library'}
    UPDATED_ENVIRONMENT = {:id => 3, :name => NEW_ENV_NAME, :description => nil, :prior => nil, :path => []}
    EMPTY_ENVIRONMENT = {:name => "", :description => "", :prior => nil, :display_name => ''}

    ORG_ID = 1
    ORGANIZATION = {:id => 1, :name => "organization_name", :description => "organization_description", :label=>"foo"}
  end

  describe "rules" do
    before (:each) do
      setup_controller_defaults
      new_test_org
    end
    describe "GET new" do
      let(:action) {:new}
      let(:req) { get :new, :organization_id => @organization.label}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :organizations,nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "post create" do
      let(:action) {:create}
      let(:req) { post :create, :organization_id => @organization.label,
                              :name => 'production', :prior => @organization.library}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :organizations,nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end

  describe "other-tests-update with with invalid params" do
    before do
      setup_controller_defaults
      new_test_org
      @environment = create_environment(:name=>"boo", :label=> "boo", :organization=> @organization, :prior => @organization.library)
    end
    let(:req) do

      bad_req = {:env_id => @environment.id, :org_id => @organization.label,
                  :kt_environment => { :name => 'production', :prior => @organization.library}
        }
      bad_req[:kt_environment][:bad_foo] = "mwahaha"
      put 'update', bad_req
    end
    it_should_behave_like "bad request"
  end

  describe "other-tests" do
    before (:each) do
      setup_controller_defaults

      #Resources::Candlepin::Owner.stubs(:merge_to).returns @org
      @env = OpenStruct.new(EnvControllerTest::ENVIRONMENT)
      @env.stubs(:successor).returns("")

      @library = OpenStruct.new(EnvControllerTest::LIBRARY)

      @org = new_test_org

      @org.stubs(:environments).returns([@env])
      @org.environments.stubs(:first).with(:conditions => {:name => @env.name}).returns(@env)
      @org.stubs(:library).returns(@library)

      KTEnvironment.stubs(:find).returns(@env)
    end

    describe "GET new" do
      before (:each) do
        @new_env = OpenStruct.new(EnvControllerTest::EMPTY_ENVIRONMENT)
      end

      it "assigns a new environment as @environment (katello)" do #TODO headpin
        @controller.expects(:render).twice
        KTEnvironment.expects(:new).returns(@new_env)
        get :new, :organization_id => @org.label
        assigns(:environment).wont_be_nil
      end
    end

    describe "GET edit" do
      it "assigns the requested environment as @environment" do
        @controller.expects(:render).twice
        get :edit, :id => @env.id, :organization_id => @org.label
        assigns(:environment).must_equal @env
      end
    end

    describe "POST create" do
      describe "with valid params" do
        before(:each) do
          @new_env = OpenStruct.new(EnvControllerTest::EMPTY_ENVIRONMENT)
          KTEnvironment.stubs(:new).returns(@new_env)
          @new_env.stubs(:save!).returns(true)
          Util::Support.stubs(:deep_copy) {|p| p}
        end

        it "should create new environment (katello)" do #TODO headpin
          KTEnvironment.expects(:new).with({:name => 'production',:label=>"boo",
                :prior => "#{@org.library}", :description => nil, :organization_id => @org.id}).returns(@new_env)
          post :create, :organization_id => @org.label, :kt_environment => {:name => 'production', :label=>"boo", :prior => "#{@org.library}"}
        end

        it "should save new environment (katello)" do #TODO headpin
          @new_env.expects(:save!).returns(true)
          post :create, :organization_id => @org.label, :kt_environment => {:name => 'production', :prior => @org.library}
        end

        it "assigns a newly created environment as @environment (katello)" do #TODO headpin
          post :create, :organization_id => @org.label, :kt_environment => {:name => 'production', :prior => @org.library}
          assigns(:environment).wont_be_nil
        end

        it "redirects to the created environment (katello)" do #TODO headpin
          post :create, :organization_id => @org.label, :kt_environment => {:name => 'production', :prior => @org.library}
          env = assigns(:environment)
          must_respond_with(:success)
        end

      end
    end

    describe "env create invalid params" do
      let(:req) do
        bad_req = {:organization_id => @organization.label, :kt_environment => {:name => 'production', :prior => @organization.library.id}}
        bad_req[:kt_environment][:bad_foo] = "mwahaha"
        post :create, bad_req
      end
      it_should_behave_like "bad request"
    end

    describe "update an environment" do
      describe "with no exceptions thrown" do

        before (:each) do
          @env.stubs(:update_attributes).returns(EnvControllerTest::UPDATED_ENVIRONMENT)
          @env.stubs(:save!)
        end

        it "should call katello environment update api (katello)" do #TODO headpin
          @env.expects(:update_attributes).returns(EnvControllerTest::UPDATED_ENVIRONMENT)
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        end

        it "should generate a success notice" do
          must_notify_with(:success)
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        end

        it "should not redirect from edit view (katello)" do #TODO headpin
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
          response.must_respond_with(:success)
        end
      end

      describe "exception is thrown in katello api" do
        before(:each) do
          errors = mock('errors')
          @env.stubs(:errors).returns(errors)
          errors.stubs(:full_messages).returns(['errors'])
          @env.stubs(:update_attributes).raises(ActiveRecord::RecordInvalid.new(@env))
          @env.stubs(:save!)
        end

        it "should generate an error notice" do
          must_notify_with(:exception)
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        end

        it "should not redirect from edit view (katello)" do #TODO headpin
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
          response.must_respond_with(422)
        end
      end
    end

    describe "destroy an environment" do
      before(:each) { @env.stubs(:destroy) }

      describe "on success" do
        before(:each) { @env.stubs(:destroyed?).returns(true) }

        it "destroys the requested environment (katello)" do #TODO headpin
          @env.expects(:destroy)
          @env.expects(:destroyed?)
          delete :destroy, :id => @env.id, :organization_id => @org.label, :format => :js
        end

        it "redirects to the environments list (katello)" do #TODO headpin
          delete :destroy, :id => @env.id, :organization_id => @org.label, :format => :js
        end
      end

      describe "on failure" do
        before(:each) { @env.stubs(:destroyed?).returns(false) }

        it "should produce an error notice on failure (katello)" do
          must_notify_with(:error)
          delete :destroy, :id => @env.id, :organization_id => @org.label
        end

        it "shouldn't render anything on failure (katello)" do
          delete :destroy, :id => @env.id, :organization_id => @org.label
          response.body.must_be :blank?
        end
      end
    end
  end
end
end
