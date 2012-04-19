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



describe SystemGroupsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include OrchestrationHelper

  before(:each) do
      set_default_locale
      login_user
      disable_org_orchestration
      disable_consumer_group_orchestration

      controller.stub(:search_validate).and_return(true)
      @org = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
      setup_current_organization(@org)


  end


  describe "Controller tests " do
    before(:each) do
      @group = SystemGroup.create!(:name=>"test_group", :organization=>@org)
    end

    describe "GET index" do
      it "requests filters using search criteria" do
        get :index
        response.should be_success
      end
    end

    describe "GET items" do
      it "requests filters using search criteria" do
        controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
          search_options[:filter][:organization_id].should include(@org.id)
          controller.stub(:render)
        }
        get :items
        response.should be_success
      end
    end

    describe "GET new" do
      it "should return successfully" do
        get :new
        response.should be_success
        assigns(:group).should_not be_nil
      end
    end

    describe "GET edit" do
      it "should return successfully" do
        get :edit, :id=>@group.id
        response.should be_success
        assigns(:group).id.should == @group.id
      end
    end

    describe "GET show" do
      it "should return successfully" do
        get :show, :id=>@group.id
        response.should be_success
        assigns(:group).id.should == @group.id
      end
    end


    describe "POST create" do
      it "should create a group correctly" do
        post :create, :system_group=>{:name=>"foo", :description=>"describe"}
        response.should be_success
        SystemGroup.where(:name=>"foo").first.should_not be_nil
      end
      it "should not create a group without a name" do
        post :create, :system_group=>{:description=>"describe"}
        response.should_not be_success
        SystemGroup.where(:description=>"describe").first.should be_nil
      end
      it "should allow two groups with the same name in different orgs" do
        @org2 = Organization.create!(:name => 'test_org2', :cp_key => 'test_org')
        setup_current_organization(@org2)
        post :create, :system_group=>{:name=>@group.name, :description=>@group.description}
        response.should be_success
        SystemGroup.where(:name=>@group.name).count.should == 2
      end
      it "should not allow a group to be created that already exists" do
        post :create, :system_group=>{:name=>@group.name, :description=>@group.description}
        response.should_not be_success
        SystemGroup.where(:name=>@group.name).count.should == 1
      end
    end

    describe "PUT update" do
      it "should allow name to be changed" do
        old_name = @group.name
        put :update, :id=>@group.id, :system_group=>{:name=>"rocky"}
        response.should be_success
        SystemGroup.where(:name=>'rocky').first.should_not be_nil
        SystemGroup.where(:name=>old_name).first.should be_nil

      end
      it "should allow locked to be toggled" do
        put :update, :id=>@group.id, :system_group=>{:locked=>"true"}
        SystemGroup.find(@group.id).locked.should == true
      end
    end

    describe "DELETE" do
      it "should complete successfully" do
        controller.stub(:render)
        delete :destroy, :id=>@group.id
        response.should be_success
        SystemGroup.where(:name=>@group.name).first.should be_nil
      end
    end

  end





end
