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

describe EnvironmentsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  module EnvControllerTest
    ENV_NAME = "environment_name"
    NEW_ENV_NAME = "another_environment_name"
    
    ENVIRONMENT = {:id => 2, :name => ENV_NAME, :description => nil, :prior => nil, :path => []}
    LIBRARY = {:id => 1, :name => "Library", :description => nil, :prior => nil, :path => []}
    UPDATED_ENVIRONMENT = {:id => 3, :name => NEW_ENV_NAME, :description => nil, :prior => nil, :path => []}
    EMPTY_ENVIRONMENT = {:name => "", :description => "", :prior => nil}
    
    ORG_ID = 1
    ORGANIZATION = {:id => 1, :name => "organization_name", :description => "organization_description", :cp_key=>"foo"}
  end

  describe "rules" do
    before (:each) do
      new_test_org
      Organization.stub!(:first).with(:conditions => {:cp_key=>@organization.cp_key}).and_return(@organization)
    end
    describe "GET new" do
      let(:action) {:new}
      let(:req) { get :new, :organization_id => @organization.cp_key}
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
      let(:req) { post :create, :organization_id => @organization.cp_key,
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
      @environment = KTEnvironment.create!(:name => "boo", :organization=> @organization, :prior => @organization.library)
    end
    it_should_behave_like "bad request"  do
      let(:req) do

        bad_req = {:env_id => @environment.id, :org_id => @organization.cp_key,
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
      controller.stub!(:notice)

      #Candlepin::Owner.stub!(:merge_to).and_return @org
      @env = mock(KTEnvironment, EnvControllerTest::ENVIRONMENT)
      @env.stub!(:successor).and_return("")

      @library = mock(KTEnvironment, EnvControllerTest::LIBRARY)

      @org = new_test_org

      @org.stub!(:environments).and_return([@env])
      @org.environments.stub!(:first).with(:conditions => {:name => @env.name}).and_return(@env)
      @org.stub!(:library).and_return(@library)

      Organization.stub!(:first).with(:conditions => {:cp_key=>@org.cp_key}).and_return(@org)
      KTEnvironment.stub!(:find).and_return(@env)
    end

    describe "GET new" do
      before (:each) do
        @new_env = mock(KTEnvironment, EnvControllerTest::EMPTY_ENVIRONMENT)
      end

      it "assigns a new environment as @environment" do
        KTEnvironment.should_receive(:new).and_return(@new_env)
        get :new, :organization_id => @org.cp_key
        assigns(:environment).should_not be_nil
      end
    end

    describe "GET edit" do
      it "assigns the requested environment as @environment" do
        get :edit, :id => @env.id, :organization_id => @org.cp_key
        assigns(:environment).should == @env
      end
    end

    describe "POST create" do
      describe "with valid params" do
        before(:each) do
          @new_env = mock(KTEnvironment, EnvControllerTest::EMPTY_ENVIRONMENT)
          KTEnvironment.stub!(:new).and_return(@new_env)
          @new_env.stub!(:save!).and_return(true)
          Support.stub!(:deep_copy) {|p| p}
        end


        it "should create new environment" do
          KTEnvironment.should_receive(:new).with({:name => 'production',
                :organization_id => @org.id, :prior => @org.library, :description => nil}).and_return(@new_env)
          post :create, :organization_id => @org.cp_key, :name => 'production', :prior => @org.library
        end

        it "should save new environment" do
          @new_env.should_receive(:save!).and_return(true)
          post :create, :organization_id => @org.cp_key, :name => 'production', :prior => @org.library
        end

        it "assigns a newly created environment as @environment" do
          post :create, :organization_id => @org.cp_key, :name => 'production', :prior => @org.library
          assigns(:environment).should_not be_nil
        end

        it "redirects to the created environment" do
          post :create, :organization_id => @org.cp_key, :name => 'production', :prior => @org.library
          env = assigns(:environment)
          response.should be_success
        end

      end
    end

    describe "env create invalid params" do
      before do
        new_test_org
      end
        it_should_behave_like "bad request"  do
          let(:req) do
            bad_req = {:organization_id => @organization.cp_key, :name => 'production', :prior => @organization.library}
            bad_req[:bad_foo] = "mwahaha"
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

        it "should call katello environment update api" do
          @env.should_receive(:update_attributes).and_return(EnvControllerTest::UPDATED_ENVIRONMENT)
          put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        end

        it "should generate a success notice" do
          controller.should_receive(:notice)
          put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        end

        it "should not redirect from edit view" do
          put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
          response.should_not be_redirect
        end
      end

      describe "exception is thrown in katello api" do
        before(:each) do
          @env.stub(:update_attributes).and_raise(Exception)
          @env.stub(:save!)
        end

        it "should generate an error notice" do
          controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
          put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        end

        it "should not redirect from edit view" do
          put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kt_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
          response.should_not be_redirect
        end
      end
    end
    describe "destroy an environment" do
        before(:each) do
          @env.stub(:destroy)
        end

      it "destroys the requested environment" do
        @env.should_receive(:destroy)
        delete :destroy, :id => @env.id, :organization_id => @org.cp_key
      end

      it "redirects to the environments list" do
        delete :destroy, :id => @env.id, :organization_id => @org.cp_key
      end
    end
  end
end
