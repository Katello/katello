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

describe UsersController do
  
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include OrganizationHelperMethods

  before(:each) do
    disable_user_orchestration
    login_user
    set_default_locale
    controller.stub(:search_validate).and_return(true)
  end

  describe "create a user" do

    before(:each) do
      controller.stub!(:notice)
      @organization = new_test_org
      @environment = KTEnvironment.create!(:name => 'first-env', :prior => @organization.library.id, :organization => @organization)
    end

    it "should create a user correctly" do
      name = "foo-user"
      post 'create', {:user => {:username=>name, :password=>"password1234", :email=>"#{name}@somewhere.com", :env_id => @environment.id}}
      response.should be_success
      User.where(:username=>name).should_not be_empty
    end
    
    it "should error if no username " do
      post 'create', {:user => {:username=>"", :password=>"password1234", :email=> "user@somewhere.com", :env_id => @environment.id}}
      response.should_not be_success
      
      post 'create', {:user => { :password=>"password1234", :email=> "user@somewhere.com", :env_id => @environment.id}}
      response.should_not be_success
    end

    it "should error if no password " do
      post 'create', {:user => {:username=>"testuser", :password=>"", :email=> "user@somewhere.com", :env_id => @environment.id}}
      response.should_not be_success
      
      post 'create', {:user => {:username=>"testuser", :email=> "user@somewhere.com", :env_id => @environment.id}}
      response.should_not be_success
    end

    it "should error if no email address " do
      post 'create', {:user => {:username=>"testuser", :password=>"password1234", :email=>"", :env_id => @environment.id}}
      response.should_not be_success
      
      post 'create', {:user => {:username=>"testuser", :password=>"password1234", :env_id => @environment.id}}
      response.should_not be_success
    end

    it_should_behave_like "bad request"  do
      let(:req) do
        name = "foo-user"
        bad_req = {:user => {:username=>name, :password=>"password1234", :email=>"#{name}@somewhere.com", :env_id => @environment.id}}
        bad_req[:user][:bad_foo] = "hahaha"
        post 'create', bad_req
      end
    end
  end
  
  describe "edit a user" do
    
    before(:each) do
      controller.stub!(:notice)
      controller.stub!(:escape_html)

      @user = User.new
      @user.username = "foo-user"
      @user.password = "password"
      @user.email = "foo-user@somewhere.com"
      @user.save 
      allow 'Test', ["create", "read","delete"], "product", ["RHEL-4", "RHEL-5","Cluster","ClusterStorage","Fedora"]
    end    
    
    it "should be allowed to change the password" do 
       put 'update', {:id => @user.id, :user => {:password=>"password1234"}}
       response.should be_success
       User.authenticate!(@user.username, "password1234").should be_true
    end
    
    it "should be allowed to change the email address" do 
       new_email = "foo-user@somewhere-new.com"
       put 'update', {:id => @user.id, :user => {:email=>new_email}}
       response.should be_success
       assert !User.where(:id => @user.id, :email => new_email).empty?
    end

    it_should_behave_like "bad request"  do
      let(:req) do
        new_email = "foo-user@somewhere-new.com"
        bad_req = {:id => @user.id, :user => {:email=>new_email}}
        bad_req[:user][:bad_foo] = "hahaha"
        put 'update', bad_req
      end
    end


    it "should not change the username" do 
       put 'update', {:id => @user.id, :user => {:username=>"FOO"}}
       response.should_not be_success
       response.status.should == 400
       assert User.where(:username=>"FOO").empty?
       assert !User.where(:username=>@user.username).empty?      
    end
    
    it "should allow roles to be changed" do
       role = Role.where(:name=>"Test")[0]
       assert !role.nil?
       put 'update_roles', {:id => @user.id, :user=>{:role_ids=>[role.id]}}
       response.should be_success
       assert User.find(@user.id).roles.size == 2
       put 'update_roles', {:id => @user.id, :user=>{:role_ids=>[]}}
       response.should be_success
       #should still have self role
       assert User.find(@user.id).roles.size == 1
    end

    it_should_behave_like "bad request"  do
      let(:req) do
        role = Role.where(:name=>"Test")[0]
        put 'update_roles', {:id => @user.id, :user=>{:bad_foo => "boo", :role_ids=>[role.id]}}
      end
    end

  end  
  
  describe "set helptips" do
    
    before(:each) do
      @user = User.new
      @user.username = "foo-user"
      @user.password = "password"
      @user.email = "foo-user@somewhere.com"
      @user.helptips_enabled = true
      @user.save!
      @user.stub(:allowed_to?).and_return true

      login_user :user => @user
    end    
    
    it "should enable and disable a helptip if user's helptips are enabled" do
      assert @user.help_tips.empty?
      post 'disable_helptip', {:key=>"apples"}
      response.should be_success
      user = User.find(@user.id)
      assert !user.help_tips.empty?
      
      post 'enable_helptip', {:key=>"apples"}      
      user = User.find(@user.id)
      assert user.help_tips.empty?      
    end
    
    it "should not enable and disable a helptip if user's helptips are disabled" do     
      post 'disable_helptip', {:key=>"apples"}
      user = User.find(@user.id)
      assert user.help_tips.size == 1    
      
      @user.helptips_enabled = false
      @user.save
      
      #disabling a 2nd helptip shouldn't cause it to be disabled
      post 'disable_helptip', {:key=>"oranges"}  
      user = User.find(@user.id)
      assert user.help_tips.size == 1    
      
      #enabling the 1st helptip shouldn't cause it to be enabled
      post 'enable_helptip', {:key=>"apples"}  
      user = User.find(@user.id)
      assert user.help_tips.size == 1          
    end
  end  

  describe "rules" do
    before (:each) do
      @organization = new_test_org
      @testuser = User.create!(:username=>"TestUser", :password=>"foobar", :email=>"TestUser@somewhere.com")
    end
    describe "GET index" do
      let(:action) {:items}
      let(:req) { get :items }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :users, nil, nil) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      let(:on_success) do
        assigns(:items).should include @testuser
      end
    end

    describe "update user put" do
      let(:action) {:update}
      let(:req) do
        put 'update', :id => @testuser.id, :user => {:password=>"barfoo"}
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :users, nil, nil) }
      end
      let(:unauthorized_user) do
         user_with_permissions { |u| u.can(:read, :users, nil, nil) }
      end
      it_should_behave_like "protected action"
    end
  end
end
