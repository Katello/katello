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

    Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Resources::Candlepin::Consumer.stub!(:update).and_return(true)
    @system = System.create!(:name=>"bar1", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end


  describe "Controller tests " do
     before(:each) do
       @group = SystemGroup.create!(:name=>"test_group", :organization=>@org, :max_systems => 5)
     end

     describe "GET index" do
      let(:action) {:index}
      let(:req) { get :index, :organization_id=>@org.cp_key}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

       it "requests filters using search criteria" do
         get :index, :organization_id=>@org.cp_key
         response.should be_success
       end
     end


     describe "GET show" do
      let(:action) {:show}
      let(:req) { get :show, :id=>@group.id, :organization_id=>@org.cp_key}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"


       it "should return successfully" do
         get :show, :id=>@group.id, :organization_id=>@org.cp_key
         response.should be_success
         assigns(:group).id.should == @group.id
       end
     end

     describe "GET history" do
      let(:action) {:history}
      let(:req) { get :history, :id=>@group.id, :organization_id=>@org.cp_key}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"


       it "should return successfully" do
         get :history, :id=>@group.id, :organization_id=>@org.cp_key
         response.should be_success
         assigns(:group).id.should == @group.id
       end
     end



     describe "POST create" do
       let(:action) {:create}
       let(:req) { post :create, :organization_id=>@org.cp_key}
       let(:authorized_user) do
         user_with_permissions { |u| u.can(:create, :system_groups, nil, @org) }
       end
       let(:unauthorized_user) do
         user_without_permissions
       end
       it_should_behave_like "protected action"

       it "should create a group correctly" do
         post :create, :organization_id=>@org.cp_key, :system_group=>{:name=>"foo", :description=>"describe", :max_systems => 5}
         response.should be_success
         SystemGroup.where(:name=>"foo").first.should_not be_nil
       end

       it "should not create a group without a name" do
         post :create, :organization_id=>@org.cp_key, :system_group=>{:description=>"describe", :max_systems => 5}
         response.should_not be_success
         SystemGroup.where(:description=>"describe").first.should be_nil
       end

       it "should allow creation of a group without specifying maximum systems" do
         post :create, :organization_id=>@org.cp_key, :system_group=>{:description=>"describe", :name => "foo"}
         response.should be_success
         SystemGroup.where(:max_systems=>"-1").count.should == 1
       end

       it "should allow creation of a group specifying maximum systems" do
         post :create, :organization_id=>@org.cp_key, :system_group=>{:description=>"describe", :name => "foo", :max_systems => "100"}
         response.should be_success
         SystemGroup.where(:max_systems=>"100").count.should == 1
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
       let(:action) {:update}
       let(:req) { put :update, :id=>@group.id, :organization_id=>@org.cp_key}
       let(:authorized_user) do
         user_with_permissions { |u| u.can(:update, :system_groups, @group.id, @org) }
       end
       let(:unauthorized_user) do
         user_without_permissions
       end
       it_should_behave_like "protected action"

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



     describe "POST add systems" do
       let(:action) {:add_systems}
       let(:req) { post :add_systems, :id=>@group.id, :organization_id=>@org.cp_key}
       let(:authorized_user) do
         user_with_permissions { |u| u.can(:update, :system_groups, @group.id, @org) }
       end
       let(:unauthorized_user) do
         user_without_permissions
       end
       it_should_behave_like "protected action"

       it "should allow adding of systems" do
         post :add_systems, :organization_id=>@org.id, :id=>@group.id,
              :system_group=>{:system_ids=>[@system.uuid]}
         response.should be_success
         @group.reload.systems.should include @system

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

     describe "POST remove systems" do
       let(:action) {:remove_systems}
       let(:req) { post :remove_systems, :id=>@group.id, :organization_id=>@org.cp_key}
       let(:authorized_user) do
         user_with_permissions { |u| u.can(:update, :system_groups, @group.id, @org) }
       end
       let(:unauthorized_user) do
         user_without_permissions
       end
       it_should_behave_like "protected action"

       it "should allow removal of systems" do
         @group.systems  = [@system]
         @group.save!
         post :remove_systems, :organization_id=>@org.id, :id=>@group.id,
              :system_group=>{:system_ids=>[@system.uuid]}
         response.should be_success
         @group.reload.systems.should_not include @system
       end

     end

    describe "POST lock group" do
      let(:action) {:lock}
      let(:req) { post :lock, :id=>@group.id, :organization_id=>@org.cp_key}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:locking, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should allow locking" do
        @group.locked = false
        @group.save!
        post :lock, :organization_id=>@org.id, :id=>@group.id
        response.should be_success
        @group.reload.locked.should == true
      end
    end

     describe "POST unlock group" do
       let(:action) {:unlock}
       let(:req) { post :unlock, :id=>@group.id, :organization_id=>@org.cp_key}
       let(:authorized_user) do
         user_with_permissions { |u| u.can(:locking, :system_groups, @group.id, @org) }
       end
       let(:unauthorized_user) do
         user_without_permissions
       end
       it_should_behave_like "protected action"

       it "should allow unlocking" do
         @group.locked = true
         @group.save!
         post :unlock, :organization_id=>@org.id, :id=>@group.id
         response.should be_success
         @group.reload.locked.should == false
       end
     end


     describe "DELETE" do
       let(:action) {:destroy}
       let(:req) { delete :destroy, :id=>@group.id, :organization_id=>@org.cp_key}
       let(:authorized_user) do
         user_with_permissions { |u| u.can(:delete, :system_groups, @group.id, @org) }
       end
       let(:unauthorized_user) do
         user_without_permissions
       end
       it_should_behave_like "protected action"


       it "should complete successfully" do
         controller.stub(:render)
         delete :destroy, :organization_id=>@org.cp_key, :id=>@group.id
         response.should be_success
         SystemGroup.where(:name=>@group.name).first.should be_nil
       end
     end

     describe "DELETE destroy_systems" do
       let(:action) {:destroy_systems}
       let(:req) { delete :destroy_systems, :id=>@group.id, :organization_id=>@org.cp_key}
       let(:authorized_user) do
         user_with_permissions { |u| u.can(:delete_systems, :system_groups, @group.id, @org) }
       end
       let(:unauthorized_user) do
         user_without_permissions
       end
       it_should_behave_like "protected action"


       it "should complete successfully" do
         @group.systems  = [@system]
         @group.save

         System.stub(:find).and_return([@system])
         @system.should_receive(:destroy)
         controller.stub(:render)

         delete :destroy_systems, :organization_id=>@org.cp_key, :id=>@group.id
         response.should be_success
         SystemGroup.where(:name=>@group.name).first.should be_nil
       end
     end


   end


end
