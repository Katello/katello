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

describe RolesController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  
  module RolesControllerTest
    ADMIN_ID = 2
    ADMIN = { :name => "admin", :id => ADMIN_ID }
    ROLE = { :name => "Foo_Role" }
  end
  
  before(:each) do
    login_user
    set_default_locale
    
    controller.stub!(:notice)
    controller.stub!(:errors)
    
    @organization = new_test_org 
    controller.stub!(:current_organization).and_return(@organization)
    
    @admin = Role.create(RolesControllerTest::ADMIN)
  end


  describe "create a role" do

    it "should create a role correctly" do
      post 'create', {:role => RolesControllerTest::ROLE }
      response.should be_success
      Role.where(:name=>RolesControllerTest::ROLE[:name]).should_not be_empty
    end
    
    it "should error if no name" do
      post 'create', {:role => {}}
      response.should_not be_success
    end

    it "should error if blank name" do
      post 'create', {:role => { :name=> "" }}
      response.should_not be_success
    end
    
  end
  
  describe "update a role" do
    before (:each) do
      @role = Role.create(RolesControllerTest::ROLE)
    end
    
    it 'should allow changing of the name' do
      put 'update', { :id => @role.id, :role => {  :name => "new_test_role_name"}}
      response.should be_success
      Role.where(:name=>"new_test_role_name").should_not be_empty
    end
    
    it "should be able to show the edit partial" do
      get :edit, :id=>@role.id
      response.should be_success
    end


=begin
    it 'should disallow changes to admin role' do
      post 'update', {:id=> RolesControllerTest::ADMIN_ID, :name=>"not an admin"}
      response.should be_success
      Role.where(:name=>"admin").should_not be_empty
    end
=end
    
  end
    
  describe "delete a role" do
    before (:each) do
      @role = Role.create(RolesControllerTest::ROLE)
    end
    
    it 'should successfully delete' do
      delete 'destroy', { :id => @role.id }
      Role.exists?(@role.id).should be_false
    end
    
    describe 'with wrong id' do
      it 'should thrown an exception' do
        delete 'destroy', { :id => 13 }
        response.should_not be_success
      end
    end
  end
  
  describe "viewing roles" do
    before (:each) do
      150.times{|a| Role.create!(:name=>"bar#{a}")}
    end

    it "should show the role 2 pane list" do
      get :index
      response.should be_success
      response.should render_template("index")
      assigns[:roles].should include Role.find(8)
      assigns[:roles].should_not include Role.find(30)
    end

    it "should return a portion of roles" do
      get :items, :offset=>25
      response.should be_success
      response.should render_template("list_items")
      assigns[:roles].should include Role.find(30)
      assigns[:roles].should_not include Role.find(8)
    end
    
  end
   
end