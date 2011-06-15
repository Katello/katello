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
  
    before(:each) do
      login_user
      set_default_locale
    end


  describe "create a user" do

    before(:each) do
      controller.stub!(:notice)
      controller.stub!(:errors)
    end

    it "should create a user correctly" do
      name = "foo-user"
      post 'create', {:user => {:username=>name, :password=>"password1234"}}
      response.should be_success
      User.where(:username=>name).should_not be_empty
    end
    
    it "should error if no username " do
      post 'create', {:user => {:username=>"", :password=>"password1234"}}
      response.should_not be_success
      
      post 'create', {:user => { :password=>"password1234"}}
      response.should_not be_success
      
    end
    
  end
  
  
  describe "edit a user" do
    
    before(:each) do
      controller.stub!(:notice)
      controller.stub!(:errors)
      controller.stub!(:escape_html)

      @user = User.new
      @user.username = "foo-user"
      @user.password = "password"
      @user.save 
      Role.allow 'Test', ["create", "read","delete"], "product", ["RHEL-4", "RHEL-5","Cluster","ClusterStorage","Fedora"]
    end    
    
    it "should be allowed to change the password" do 
       put 'update', {:id => @user.username, :user => {:password=>"password1234"}}
       response.should be_success
       assert User.where(:username=>@user.username)[0].password == "password1234"
    end
    
    it "should not change the username" do 
       put 'update', {:id => @user.username, :user => {:username=>"FOO"}}
       response.should be_success
       assert User.where(:username=>"FOO").empty?
       assert !User.where(:username=>@user.username).empty?      
    end
    
    it "should allow roles to be changed" do
       role = Role.where(:name=>"Test")[0]
       assert !role.nil?
       put 'update', {:id => @user.username, :user=>{:role_ids=>[role.id]}}
       response.should be_success
       assert User.find(@user.id).roles.size == 2
       put 'update', {:id => @user.username, :user=>{:role_ids=>[]}}
       response.should be_success
       #should still have self role
       assert User.find(@user.id).roles.size == 1

    end

  end  
  
  describe "set helptips" do
    
    before(:each) do
      @user = User.new
      @user.username = "foo-user"
      @user.password = "password"
      @user.helptips_enabled = true
      @user.save 
      login_user :user => @user
    end    
    
    it "should enable and disable a helptip if user's helptips are enabled" do
      assert @user.help_tips.empty?
      post 'disable_helptip', {:key=>"apples"}
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

end
