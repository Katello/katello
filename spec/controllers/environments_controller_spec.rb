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

  module EnvControllerTest
    ENV_NAME = "environment_name"
    NEW_ENV_NAME = "another_environment_name"
    
    ENVIRONMENT = {:id => 2, :name => ENV_NAME, :description => nil, :prior => nil, :path => []}
    LOCKER = {:id => 1, :name => "Locker", :description => nil, :prior => nil, :path => []}
    UPDATED_ENVIRONMENT = {:id => 3, :name => NEW_ENV_NAME, :description => nil, :prior => nil, :path => []}
    EMPTY_ENVIRONMENT = {:name => "", :description => "", :prior => nil}
    
    ORG_ID = 1
    ORGANIZATION = {:id => 1, :name => "organization_name", :description => "organization_description", :cp_key=>"foo"}
  end
  
  before (:each) do
    login_user
    set_default_locale
    controller.stub!(:notice)
    controller.stub!(:errors)
    
    #Candlepin::Owner.stub!(:merge_to).and_return @org
    @env = mock(KPEnvironment, EnvControllerTest::ENVIRONMENT)
    @env.stub!(:successor).and_return("")
     
    @locker = mock(KPEnvironment, EnvControllerTest::LOCKER)
    
    @org = mock(Organization, EnvControllerTest::ORGANIZATION)
    @org.stub!(:environments).and_return([@env])
    @org.environments.stub!(:first).with(:conditions => {:name => @env.name}).and_return(@env)
    @org.stub!(:locker).and_return(@locker)

    Organization.stub!(:first).with(:conditions => {:cp_key=>@org.cp_key}).and_return(@org)
    KPEnvironment.stub!(:find).and_return(@env)
  end

  describe "GET new" do
    before (:each) do
      @new_env = mock(KPEnvironment, EnvControllerTest::EMPTY_ENVIRONMENT)
    end

    it "assigns a new environment as @environment" do
      KPEnvironment.should_receive(:new).and_return(@new_env)
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
        @new_env = mock(KPEnvironment, EnvControllerTest::EMPTY_ENVIRONMENT)
        KPEnvironment.stub!(:new).and_return(@new_env)
        @new_env.stub!(:save!).and_return(true)
      end


      it "should create new environment" do
        KPEnvironment.should_receive(:new).with({:name => 'production',
              :organization_id => @org.id, :prior => @org.locker, :description => nil}).and_return(@new_env)
        post :create, :organization_id => @org.cp_key, :name => 'production', :prior => @org.locker
      end

      it "should save new environment" do
        @new_env.should_receive(:save!).and_return(true)
        post :create, :organization_id => @org.cp_key, :name => 'production', :prior => @org.locker
      end

      it "assigns a newly created environment as @environment" do
        post :create, :organization_id => @org.cp_key, :name => 'production', :prior => @org.locker
        assigns(:environment).should_not be_nil
      end

      it "redirects to the created environment" do
        post :create, :organization_id => @org.cp_key, :name => 'production', :prior => @org.locker
        env = assigns(:environment)
        response.should be_success
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
        put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kp_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
      end

      it "should generate a success notice" do
        controller.should_receive(:notice)
        put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kp_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
      end
      
      it "should not redirect from edit view" do
        put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kp_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        response.should_not redirect_to()
      end
    end
    
    describe "exception is thrown in katello api" do
      before(:each) do
        @env.stub(:update_attributes).and_raise(Exception)
        @env.stub(:save!)
      end
      
      it "should generate an error notice" do
        controller.should_receive(:errors)
        put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kp_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
      end
      
      it "should not redirect from edit view" do
        put 'update', :env_id => @env.id, :org_id => @org.cp_key, :kp_environment => {:name => EnvControllerTest::NEW_ENV_NAME}
        response.should_not redirect_to()
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
