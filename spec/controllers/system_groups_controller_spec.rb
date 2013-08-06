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

describe SystemGroupsController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include OrchestrationHelper
  include SystemHelperMethods
  include AuthorizationHelperMethods

  let(:uuid) { '1234' }
  before(:each) do
    set_default_locale
    login_user :mock=>false
    disable_org_orchestration
    disable_consumer_group_orchestration

    controller.stub(:search_validate).and_return(true)
    @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
    @environment = create_environment(:name=>"DEV", :label=> "DEV", :prior=>@org.library, :organization=>@org)
    @org = @org.reload
    setup_current_organization(@org)
    setup_system_creation
    Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Resources::Candlepin::Consumer.stub!(:update).and_return(true)
    Resources::Candlepin::Consumer.stub!(:destroy).and_return(true)
    Katello.pulp_server.extensions.consumer.stub!(:delete).and_return(true)

    @system = create_system(:name=>"bar1", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
  end


  describe "Controller tests " do
    before(:each) do
      @group = SystemGroup.create!(:name=>"test_group", :organization=>@org)
    end

    describe "GET index" do
      let(:action) {:index}
      let(:req) { get :index }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "requests filters using search criteria" do
        get :index
        response.should be_success
      end
    end

    describe "GET items" do

      let(:action) {:items}
      let(:req) { get :items }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"


      it "requests filters using search criteria" do
        controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
          search_options[:filter][1][:organization_id].should include(@org.id)
          controller.stub(:render)
        }
        get :items
        response.should be_success
      end
    end

    describe "GET new" do

      let(:action) {:new}
      let(:req) { get :new }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:create, :system_groups, nil, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should return successfully" do
        get :new
        response.should be_success
        assigns(:group).should_not be_nil
      end
    end

    describe "GET edit" do
      let(:action) {:edit}
      let(:req) { get :edit, :id=>@group.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should return successfully" do
        get :edit, :id=>@group.id
        response.should be_success
        assigns(:group).id.should == @group.id
      end
    end

    describe "GET show" do
      let(:action) {:show}
      let(:req) { get :show, :id=>@group.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"


      it "should return successfully" do
        get :show, :id=>@group.id
        response.should be_success
        assigns(:group).id.should == @group.id
      end
    end

    describe "POST create" do

      let(:action) {:create}
      let(:req) { post :create }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:create, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"


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
        @org2 = Organization.create!(:name=>'test_org2', :label=> 'test_org2')
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

    describe "POST copy" do
      before(:each) do
        @group.max_systems = 10
        @group.systems = [@system]
        @group.save
      end

      let(:action) {:copy}
      let(:req) { post :copy, :id => @group.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:create, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should copy a group correctly" do
        controller.should notify.success
        post :copy, :id => @group.id, :name=>"foo", :description=>"describe"
        response.should be_success
        SystemGroup.where(:name=>"foo", :description=>"describe", :max_systems=>10).first.should_not be_nil
      end
      it "should copy without a description provided" do
        controller.should notify.success
        post :copy, :id => @group.id, :name=>"foo"
        response.should be_success
        SystemGroup.where(:name=>"foo", :max_systems=>10).first.should_not be_nil
      end
      it "should not copy a group without a name" do
        controller.should notify.exception
        post :copy, :id => @group.id, :description=>"describe"
        response.should_not be_success
        SystemGroup.where(:description=>"describe").first.should be_nil
      end
      it "should not allow a group to be copied with a name that already exists" do
        controller.should notify.exception
        post :copy, :id => @group.id, :name=>@group.name, :description=>"describe"
        response.should_not be_success
        SystemGroup.where(:name=>@group.name).count.should == 1
      end
    end

    describe "PUT update" do

      let(:action) {:update}
      let(:req) { post :update, :id=>@group.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should allow name to be changed" do
        old_name = @group.name
        put :update, :id=>@group.id, :system_group=>{:name=>"rocky"}
        response.should be_success
        SystemGroup.where(:name=>'rocky').first.should_not be_nil
        SystemGroup.where(:name=>old_name).first.should be_nil

      end
    end


    describe "POST add systems" do
      it "should allow adding of systems" do
        post :add_systems, :id=>@group.id, :system_ids=>[@system.id]
        response.should be_success
        @group.reload.systems.should include @system
      end

      let(:action) {:add_systems}
        let(:req) { post :add_systems, :id=>@group.id, :system_ids=>[] }
        let(:authorized_user) do
          user_with_permissions { |u| u.can(:update, :system_groups, @group.id, @org) }
        end
        let(:unauthorized_user) do
          user_without_permissions
        end
        it_should_behave_like "protected action"
    end


    describe "POST remove_systems" do
      let(:action) {:remove_systems}
      let(:req) { post :remove_systems, :id=>@group.id, :system_ids=>[] }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should allow removal of systems" do
        @group.systems  = [@system]
        @group.save
        post :remove_systems, :id=>@group.id, :system_ids=>[@system.id]
        response.should be_success
        @group.reload.systems.should_not include @system
      end
    end


    describe "DELETE destroy" do
      let(:action) {:destroy}
      let(:req) { delete :destroy, :id=>@group.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:delete, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"


      it "should complete successfully" do
        controller.stub(:render)
        delete :destroy, :id=>@group.id
        response.should be_success
        SystemGroup.where(:name=>@group.name).first.should be_nil
      end
    end

    describe "DELETE destroy_systems" do
      let(:action) {:destroy_systems}
      let(:req) { delete :destroy_systems, :id=>@group.id}
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

        delete :destroy_systems, :id=>@group.id
        response.should be_success
        SystemGroup.where(:name=>@group.name).first.should be_nil
      end
    end

    describe "GET edit_systems" do
      let(:action) {:edit_systems}
      let(:req) { get :edit_systems, :id => @group.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update_systems, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should render edit_systems partial" do
        get :edit_systems, :id => @group.id
        response.should be_success
        response.should render_template(:partial => '_edit_systems')
      end
    end

    describe "PUT update_systems" do
      before(:each) do
        Resources::Candlepin::Consumer.stub!(:get).and_return({:uuid => uuid, :owner => {:key => uuid}})

        @next_environment = create_environment(:name => "TEST", :label => "TEST", :prior => @environment,
                                                 :organization => @org)
        promote_content_view(@environment.content_views.first, @environment, @next_environment)
        @system2 = create_system(:name=>"bar2", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})

        @group.systems = [@system, @system2]
        @group.save
      end

      let(:action) {:update_systems}
      let(:req) { put :update_systems, :id => @group.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update_systems, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"


      it "should update all systems successfully" do
        controller.should notify.success

        put :update_systems, :id => @group.id, :update_fields => {:environment_id => @next_environment.id}

        response.should be_success
        @system.reload.environment.should == @next_environment
        @system2.reload.environment.should == @next_environment
      end

      it "should update only specified systems successfully" do
        controller.should notify.success

        put :update_systems, :id => @group.id, :systems => {@system.id.to_s => @system.id.to_s},
            :update_fields => {:environment_id => @next_environment.id}

        response.should be_success
        @system.reload.environment.should == @next_environment
        @system2.reload.environment.should == @environment
      end
    end

  end
end
