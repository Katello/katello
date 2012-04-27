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

require 'spec_helper.rb'

describe Api::SystemGroupsController do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include SystemHelperMethods


  let(:uuid) { '1234' }

  before(:each) do
    disable_org_orchestration
    disable_consumer_group_orchestration

    @org = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
    @environment = KTEnvironment.create!(:name => 'test_1', :prior => @org.library.id, :organization => @org)

    setup_system_creation

    Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Candlepin::Consumer.stub!(:update).and_return(true)
    @system = System.create!(:name=>"bar1", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end


  describe "Controller tests " do
     before(:each) do
       @group = SystemGroup.create!(:name=>"test_group", :organization=>@org)
     end

     describe "GET index" do
       it "requests filters using search criteria" do
         get :index, :organization_id=>@org.cp_key
         response.should be_success
       end
     end


     describe "GET show" do
       it "should return successfully" do
         get :show, :id=>@group.id, :organization_id=>@org.cp_key
         response.should be_success
         assigns(:group).id.should == @group.id
       end
     end


     describe "POST create" do
       it "should create a group correctly" do
         post :create, :organization_id=>@org.cp_key, :system_group=>{:name=>"foo", :description=>"describe"}
         response.should be_success
         SystemGroup.where(:name=>"foo").first.should_not be_nil
       end
       it "should not create a group without a name" do
         post :create, :organization_id=>@org.cp_key, :system_group=>{:description=>"describe"}
         response.should_not be_success
         SystemGroup.where(:description=>"describe").first.should be_nil
       end
       it "should allow two groups with the same name in different orgs" do
         @org2 = Organization.create!(:name => 'test_org2', :cp_key => 'test_org2')
         #setup_current_organization(@org2)
         post :create, :organization_id=>@org2.cp_key, :system_group=>{:name=>@group.name, :description=>@group.description}
         response.should be_success
         SystemGroup.where(:name=>@group.name).count.should == 2
       end
       it "should not allow a group to be created that already exists" do
         post :create, :organization_id=>@org.cp_key, :system_group=>{:name=>@group.name, :description=>@group.description}
         response.should_not be_success
         SystemGroup.where(:name=>@group.name).count.should == 1
       end
     end

     describe "PUT update" do
       it "should allow name to be changed" do
         old_name = @group.name
         put :update, :organization_id=>@org.cp_key, :id=>@group.id, :system_group=>{:name=>"rocky"}
         response.should be_success
         SystemGroup.where(:name=>'rocky').first.should_not be_nil
         SystemGroup.where(:name=>old_name).first.should be_nil
       end
       it "should allow systems to be changed" do
         put :update, :organization_id=>@org.cp_key, :id=>@group.id, :system_group=>{:system_ids=>[@system.uuid]}
         response.should be_success
         @group.reload.systems.should == [@system]
       end
     end



     describe "POST add/remove systems" do
       it "should allow adding of systems" do
         post :add_systems, :organization_id=>@org.id, :id=>@group.id,
              :system_group=>{:system_ids=>[@system.uuid]}
         response.should be_success
         @group.systems.should include @system

       end
       it "should allow removal of systems" do
         @group.systems  = [@system]
         @group.save!
         post :remove_systems, :organization_id=>@org.id, :id=>@group.id,
              :system_group=>{:system_ids=>[@system.uuid]}
         response.should be_success
         @group.reload.systems.should_not include @system
       end

       it "should not allow addition if locked" do
         @group.locked = true
         @group.save!
         post :add_systems, :organization_id=>@org.id, :id=>@group.id,
              :system_group=>{:system_ids=>[@system.uuid]}
         response.should_not be_success
         @group.systems.should_not include @system
       end
     end

    describe "POST lock/unlock group" do
      it "should allow locking" do
        @group.locked = false
        @group.save!
        post :lock, :organization_id=>@org.id, :id=>@group.id
        response.should be_success
        @group.reload.locked.should == true
      end
      it "should allow locking" do
        @group.locked = true
        @group.save!
        post :unlock, :organization_id=>@org.id, :id=>@group.id
        response.should be_success
        @group.reload.locked.should == false
      end
    end


     describe "DELETE" do
       it "should complete successfully" do
         controller.stub(:render)
         delete :destroy, :organization_id=>@org.cp_key, :id=>@group.id
         response.should be_success
         SystemGroup.where(:name=>@group.name).first.should be_nil
       end
     end

   end


end
