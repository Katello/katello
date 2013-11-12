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

require 'katello_test_helper'

module Katello
describe SystemGroupsController do

  include LocaleHelperMethods
  include OrganizationHelperMethods
  include OrchestrationHelper
  include SystemHelperMethods
  include AuthorizationHelperMethods

  describe "(katello)" do

  let(:uuid) { '1234' }
  before(:each) do
    setup_controller_defaults
    disable_org_orchestration
    disable_consumer_group_orchestration

    @controller.stubs(:search_validate).returns(true)
    @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
    @environment = create_environment(:name=>"DEV", :label=> "DEV", :prior=>@org.library, :organization=>@org)
    @org = @org.reload
    @controller.stubs(:current_organization).returns(@org)
    setup_system_creation
    Resources::Candlepin::Consumer.stubs(:create).returns({:uuid => uuid, :owner => {:key => uuid}})
    Resources::Candlepin::Consumer.stubs(:update).returns(true)
    Resources::Candlepin::Consumer.stubs(:destroy).returns(true)
    SystemGroup.any_instance.stubs(:set_pulp_consumer_group).returns({})
    SystemGroup.any_instance.stubs(:del_pulp_consumer_group).returns({})
    SystemGroup.any_instance.stubs(:add_consumer).returns({})
    SystemGroup.any_instance.stubs(:remove_consumer).returns({})
    System.any_instance.stubs(:update_pulp_consumer).returns({})
    System.any_instance.stubs(:del_pulp_consumer).returns({})
    Katello.pulp_server.extensions.consumer.stubs(:delete).returns(true)

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
        must_respond_with(:success)
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
        @controller.stubs(:render)
        @controller.expects(:render_panel_direct)
        get :items
        must_respond_with(:success)
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
        must_respond_with(:success)
        assigns(:group).wont_be_nil
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
        must_respond_with(:success)
        assigns(:group).id.must_equal @group.id
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
        must_respond_with(:success)
        assigns(:group).id.must_equal @group.id
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
        must_respond_with(:success)
        SystemGroup.where(:name=>"foo").first.wont_be_nil
      end
      it "should not create a group without a name" do
        post :create, :system_group=>{:description=>"describe"}
        response.must_respond_with(422)
        SystemGroup.where(:description=>"describe").first.must_be_nil
      end
      it "should allow two groups with the same name in different orgs" do
        @org2 = Organization.create!(:name=>'test_org2', :label=> 'test_org2')
        @controller.stubs(:current_organization).returns(@org2)
        post :create, :system_group=>{:name=>@group.name, :description=>@group.description}
        must_respond_with(:success)
        SystemGroup.where(:name=>@group.name).count.must_equal 2
      end
      it "should not allow a group to be created that already exists" do
        post :create, :system_group=>{:name=>@group.name, :description=>@group.description}
        response.must_respond_with(422)
        SystemGroup.where(:name=>@group.name).count.must_equal 1
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
        must_notify_with(:success)
        post :copy, :id => @group.id, :name=>"foo", :description=>"describe"
        must_respond_with(:success)
        SystemGroup.where(:name=>"foo", :description=>"describe", :max_systems=>10).first.wont_be_nil
      end
      it "should copy without a description provided" do
        must_notify_with(:success)
        post :copy, :id => @group.id, :name=>"foo"
        must_respond_with(:success)
        SystemGroup.where(:name=>"foo", :max_systems=>10).first.wont_be_nil
      end
      it "should not copy a group without a name" do
        must_notify_with(:exception)
        post :copy, :id => @group.id, :description=>"describe"
        response.must_respond_with(422)
        SystemGroup.where(:description=>"describe").first.must_be_nil
      end
      it "should not allow a group to be copied with a name that already exists" do
        must_notify_with(:exception)
        post :copy, :id => @group.id, :name=>@group.name, :description=>"describe"
        response.must_respond_with(422)
        SystemGroup.where(:name=>@group.name).count.must_equal 1
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
        must_respond_with(:success)
        SystemGroup.where(:name=>'rocky').first.wont_be_nil
        SystemGroup.where(:name=>old_name).first.must_be_nil

      end
    end

    describe "POST add systems" do
      it "should allow adding of systems" do
        post :add_systems, :id=>@group.id, :system_ids=>[@system.id]
        must_respond_with(:success)
        @group.reload.systems.must_include @system
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
        must_respond_with(:success)
        @group.reload.systems.wont_include @system
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
        @controller.stubs(:render)
        delete :destroy, :id=>@group.id
        must_respond_with(:success)
        SystemGroup.where(:name=>@group.name).first.must_be_nil
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
        must_respond_with(:success)
        SystemGroup.where(:name=>@group.name).first.must_be_nil
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
        must_respond_with(:success)
        must_render_template(:partial => '_edit_systems')
      end
    end

    describe "PUT update_systems" do
      before(:each) do
        Resources::Candlepin::Consumer.stubs(:get).returns({:uuid => uuid, :owner => {:key => uuid}})

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
        must_notify_with(:success)

        put :update_systems, :id => @group.id, :update_fields => {:environment_id => @next_environment.id}

        must_respond_with(:success)
        @system.reload.environment.must_equal @next_environment
        @system2.reload.environment.must_equal @next_environment
      end

      it "should update only specified systems successfully" do
        must_notify_with(:success)

        put :update_systems, :id => @group.id, :systems => {@system.id.to_s => @system.id.to_s},
            :update_fields => {:environment_id => @next_environment.id}

        must_respond_with(:success)
        @system.reload.environment.must_equal @next_environment
        @system2.reload.environment.must_equal @environment
      end
    end

  end
  end
end
end
