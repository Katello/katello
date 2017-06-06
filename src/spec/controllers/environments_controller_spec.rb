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

describe EnvironmentsController do
  include LoginHelperMethods
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
      login_user
      set_default_locale
      new_test_org
      @environment = KTEnvironment.create!(:name=>"boo", :label=> "boo", :organization=> @organization, :prior => @organization.library)
    end
    it_should_behave_like "bad request"  do
      let(:req) do

        bad_req = {:env_id => @environment.id, :org_id => @organization.label,
                    :kt_environment => { :name => 'production', :prior => @organization.library}
          }
        bad_req[:kt_environment][:bad_foo] = "mwahaha"
        put 'update', bad_req
      end
    end
  end


  describe "other-tests" do
    before (:each) do
      login_user
      set_default_locale

      #Resources::Candlepin::Owner.stub!(:merge_to).and_return @org
      @env = mock(KTEnvironment, EnvControllerTest::ENVIRONMENT)
      @env.stub!(:successor).and_return("")

      @library = mock(KTEnvironment, EnvControllerTest::LIBRARY)

      @org = new_test_org

      @org.stub!(:environments).and_return([@env])
      @org.environments.stub!(:first).with(:conditions => {:name => @env.name}).and_return(@env)
      @org.stub!(:library).and_return(@library)

      KTEnvironment.stub!(:find).and_return(@env)
    end

    describe "GET new" do
      before (:each) do
        @new_env = mock(KTEnvironment, EnvControllerTest::EMPTY_ENVIRONMENT)
      end

      it "assigns a new environment as @environment", :katello => true do #TODO headpin
        KTEnvironment.should_receive(:new).and_return(@new_env)
        get :new, :organization_id => @org.label
        assigns(:environment).should_not be_nil
      end
    end

    describe "GET edit" do
      it "assigns the requested environment as @environment" do
        get :edit, :id => @env.id, :organization_id => @org.label
        assigns(:environment).should == @env
      end
    end

    describe "POST create" do
      describe "with valid params" do
        before(:each) do
          @new_env = mock(KTEnvironment, EnvControllerTest::EMPTY_ENVIRONMENT)
          KTEnvironment.stub!(:new).and_return(@new_env)
          @new_env.stub!(:save!).and_return(true)
          Util::Support.stub!(:deep_copy) {|p| p}
        end


        it "should create new environment", :katello => true do #TODO headpin
          KTEnvironment.should_receive(:new).with({:name => 'production',:label=>"boo",
                :prior => "#{@org.library}", :description => nil, :organization_id => @org.id}).and_return(@new_env)
          post :create, :organization_id => @org.label, :kt_environment => {:name => 'production', :label=>"boo", :prior => "#{@org.library}"}
        end

        it "should save new environment", :katello => true do #TODO headpin
          @new_env.should_receive(:save!).and_return(true)
          post :create, :organization_id => @org.label, :kt_environment => {:name => 'production', :prior => @org.library}
        end

        it "assigns a newly created environment as @environment", :katello => true do #TODO headpin
          post :create, :organization_id => @org.label, :kt_environment => {:name => 'production', :prior => @org.library}
          assigns(:environment).should_not be_nil
        end

        it "redirects to the created environment", :katello => true do #TODO headpin
          post :create, :organization_id => @org.label, :kt_environment => {:name => 'production', :prior => @org.library}
          env = assigns(:environment)
          response.should be_success
        end

      end
    end

    pending "env create invalid params" do
        it_should_behave_like "bad request"  do
          let(:req) do
            bad_req = {:organization_id => @organization.label, :kt_environment => {:name => 'production', :prior => @organization.library.id}}
            bad_req[:kt_environment][:bad_foo] = "mwahaha"
            post :create, bad_req
          end
        end
    end

    describe "update an environment" do
      describe "with no exceptions thrown" do

        before (:each) do
          @env.stub(:update_attributes).and_return(EnvControllerTest::UPDATED_ENVIRONMENT)
          @env.stub(:save!)
        end

        it "should call katello environment update api", :katello => true do #TODO headpin
          @env.should_receive(:update_attributes).and_return(EnvControllerTest::UPDATED_ENVIRONMENT)
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        end

        it "should generate a success notice" do
          controller.should notify.success
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        end

        it "should not redirect from edit view", :katello => true do #TODO headpin
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
          response.should_not be_redirect
        end
      end

      describe "exception is thrown in katello api" do
        before(:each) do
          errors = mock('errors')
          @env.stub!(:errors).and_return(errors)
          errors.stub!(:full_messages).and_return(['errors'])
          @env.stub(:update_attributes).and_raise(ActiveRecord::RecordInvalid.new(@env))
          @env.stub(:save!)
        end

        it "should generate an error notice" do
          controller.should notify.exception
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        end

        it "should not redirect from edit view", :katello => true do #TODO headpin
          put 'update', :env_id => @env.id, :org_id => @org.label, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
          response.should_not be_redirect
        end
      end
    end
    describe "destroy an environment" do
        before(:each) do
          @env.stub(:destroy)
        end

      it "destroys the requested environment", :katello => true do #TODO headpin
        @env.should_receive(:destroy)
        delete :destroy, :id => @env.id, :organization_id => @org.label
      end

      it "redirects to the environments list", :katello => true do #TODO headpin
        delete :destroy, :id => @env.id, :organization_id => @org.label
      end
    end
  end
end
