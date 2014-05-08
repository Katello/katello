#
# Copyright 2014 Red Hat, Inc.
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
describe Api::V1::HostCollectionsController do
  include AuthorizationHelperMethods
  include OrganizationHelperMethods
  include OrchestrationHelper
  include SystemHelperMethods

  let(:uuid) { '1234' }

  describe "(katello)" do

  before(:each) do
    disable_org_orchestration

    index_mock = stub_everything("index")
    HostCollection.stubs(:index).returns(index_mock)
    System.any_instance.stubs(:update_host_collections)

    @org         = Organization.create!(:name => 'test_org', :label => 'test_org')
    @environment = create_environment(:name => 'test_1', :label => 'test_1', :prior => @org.library.id, :organization => @org)

    setup_system_creation

    Resources::Candlepin::Consumer.stubs(:create).returns({ :uuid => uuid, :owner => { :key => uuid } })
    Resources::Candlepin::Consumer.stubs(:update).returns(true)
    Resources::Candlepin::Consumer.stubs(:destroy).returns(true)
    Katello.pulp_server.extensions.consumer.stubs(:delete).returns(true)

    HostCollection.any_instance.stubs(:set_pulp_consumer_group).returns({})
    HostCollection.any_instance.stubs(:del_pulp_consumer_group).returns({})
    HostCollection.any_instance.stubs(:add_consumer).returns({})
    HostCollection.any_instance.stubs(:remove_consumer).returns({})

    @system = create_system(:name => "bar1", :environment => @environment, :cp_type => "system", :facts => { "Test" => "" })

    @request.env["HTTP_ACCEPT"] = "application/json"
    setup_controller_defaults_api
  end

  describe "Controller tests " do
    before(:each) do
      @host_collection = HostCollection.create!(:name => "test_collection", :organization => @org, :max_content_hosts => 5)
      Glue::ElasticSearch::Items.any_instance.stubs(:retrieve).returns([0, Util::Support.array_with_total])
    end

    describe "GET index" do
      let(:action) { :index }
      let(:req) { get :index, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :host_collections, @host_collection.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "requests filters using search criteria" do
        Glue::ElasticSearch::Items.any_instance.expects(:retrieve).returns([@host_collection], 1)
        get :index, :organization_id => @org.label
        must_respond_with(:success)
      end
    end

    describe "GET show" do
      let(:action) { :show }
      let(:req) { get :show, :id => @host_collection.id, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :host_collections, @host_collection.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should return successfully" do
        get :show, :id => @host_collection.id, :organization_id => @org.label
        must_respond_with(:success)
        assigns(:host_collection).id.must_equal @host_collection.id
      end
    end

    describe "GET history" do
      let(:action) { :history }
      let(:req) { get :history, :id => @host_collection.id, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :host_collections, @host_collection.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should return successfully" do
        get :history, :id => @host_collection.id, :organization_id => @org.label
        must_respond_with(:success)
        assigns(:host_collection).id.must_equal @host_collection.id
      end
    end

    describe "POST create" do
      let(:action) { :create }
      let(:req) { post :create, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:create, :host_collections, nil, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should refresh ES index" do
        HostCollection.index.expects(:refresh)
        post :create, :organization_id => @org.label, :host_collection => { :name => "foo", :description => "describe", :max_content_hosts => 5 }
      end

      it "should create a host collection correctly" do
        post :create, :organization_id => @org.label, :host_collection => { :name => "foo", :description => "describe", :max_content_hosts => 5 }
        must_respond_with(:success)
        HostCollection.where(:name => "foo").first.wont_be_nil
      end

      it "should not create a host collection without a name" do
        post :create, :organization_id => @org.label, :host_collection => { :description => "describe", :max_content_hosts => 5 }
        response.must_respond_with(422)
        HostCollection.where(:description => "describe").first.must_be_nil
      end

      it "should allow creation of a host collection without specifying maximum content hosts" do
        count = HostCollection.where(:max_content_hosts => "-1").count
        post :create, :organization_id => @org.label, :host_collection => { :description => "describe", :name => "foo" }
        must_respond_with(:success)
        HostCollection.where(:max_content_hosts => "-1").count.must_equal count+1
      end

      it "should allow creation of a host collection specifying maximum content hosts" do
        post :create, :organization_id => @org.label, :host_collection => { :description => "describe", :name => "foo", :max_content_hosts => "100" }
        must_respond_with(:success)
        HostCollection.where(:max_content_hosts => "100").count.must_equal 1
      end

      it "should allow two host collections with the same name in different orgs" do
        @org2 = Organization.create!(:name => 'test_org2', :label => 'test_org2', :label => 'test_org2')
        #setup_current_organization(@org2)
        post :create, :organization_id => @org2.label, :host_collection => { :name => @host_collection.name, :description => @host_collection.description }
        must_respond_with(:success)
        HostCollection.where(:name => @host_collection.name).count.must_equal 2
      end

      it "should not allow a host collection to be created that already exists" do
        post :create, :organization_id => @org.label, :host_collection => { :name => @host_collection.name, :description => @host_collection.description }
        response.must_respond_with(422)
        HostCollection.where(:name => @host_collection.name).count.must_equal 1
      end
    end

    describe "POST copy" do
      let(:action) { :copy }
      let(:req) { post :copy, :id => @host_collection.id, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:create, :host_collections, nil, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should create a host collection correctly" do
        post :copy, :organization_id => @org.label, :id => @host_collection.id, :host_collection => { :new_name => "foo", :description => "describe", :max_content_hosts => 1234 }
        must_respond_with(:success)
        first = HostCollection.where(:name => "foo").first
        first.wont_be_nil
        first[:max_content_hosts].must_equal 1234
        first[:description].must_equal "describe"
      end

      it "should not create 2 host collections with the same name" do
        post :copy, :organization_id => @org.label, :id => @host_collection.id, :host_collection => { :new_name => @host_collection.name, :description => "describe" }
        response.must_respond_with(422)
        HostCollection.where(:name => @host_collection.name).count.must_equal 1
      end

      it "should inherit fields from existing host collection" do
        post :copy, :organization_id => @org.label, :id => @host_collection.id, :host_collection => { :new_name => "foo" }
        must_respond_with(:success)
        first = HostCollection.where(:name => "foo").first
        first[:max_content_hosts].must_equal @host_collection.max_content_hosts
        first[:description].must_equal @host_collection.description
      end

      it "should not let you copy one host collection to a different org" do
        @org2 = Organization.create!(:name => 'test_org2', :label => 'test_org2')
        post :copy, :organization_id => @org2.label, :id => @host_collection.id, :host_collection => { :new_name => "foo2", :description => "describe" }
        response.must_respond_with(400)
        HostCollection.where(:name => "foo2").count.must_equal 0
      end

    end

    describe "PUT update" do
      let(:action) { :update }
      let(:req) { put :update, :id => @host_collection.id, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :host_collections, @host_collection.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should refresh ES index" do
        HostCollection.index.expects(:refresh)
        put :update, :organization_id => @org.label, :id => @host_collection.id, :host_collection => { :name => "rocky" }
      end

      it "should allow name to be changed" do
        old_name = @host_collection.name
        put :update, :organization_id => @org.label, :id => @host_collection.id, :host_collection => { :name => "rocky" }
        must_respond_with(:success)
        HostCollection.where(:name => 'rocky').first.wont_be_nil
        HostCollection.where(:name => old_name).first.must_be_nil
      end
      it "should allow systems to be changed" do
        put :update, :organization_id => @org.label, :id => @host_collection.id, :host_collection => { :system_ids => [@system.uuid] }
        must_respond_with(:success)
        @host_collection.reload.systems.must_equal [@system]
      end
    end

    describe "POST add systems" do
      let(:action) { :add_systems }
      let(:req) { post :add_systems, :id => @host_collection.id, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :host_collections, @host_collection.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should allow adding of systems" do
        post :add_systems, :organization_id => @org.id, :id => @host_collection.id,
             :host_collection                  => { :system_ids => [@system.uuid] }
        must_respond_with(:success)
        @host_collection.reload.systems.must_include @system

      end
    end

    describe "POST remove systems" do
      let(:action) { :remove_systems }
      let(:req) { post :remove_systems, :id => @host_collection.id, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :host_collections, @host_collection.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should allow removal of systems" do
        @host_collection.systems = [@system]
        @host_collection.save!
        post :remove_systems, :organization_id => @org.id, :id => @host_collection.id,
             :host_collection                     => { :system_ids => [@system.uuid] }
        must_respond_with(:success)
        @host_collection.reload.systems.wont_include(@system)
      end

    end

    describe "DELETE" do
      let(:action) { :destroy }
      let(:req) { delete :destroy, :id => @host_collection.id, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:delete, :host_collections, @host_collection.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should complete successfully" do
        @controller.stubs(:render)
        delete :destroy, :organization_id => @org.label, :id => @host_collection.id
        must_respond_with(:success)
        HostCollection.where(:name => @host_collection.name).first.must_be_nil
      end
    end

    describe "DELETE destroy_systems" do
      let(:action) { :destroy_systems }
      let(:req) { delete :destroy_systems, :id => @host_collection.id, :organization_id => @org.label }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:delete_systems, :host_collections, @host_collection.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should complete successfully" do
        @host_collection.systems = [@system]
        @host_collection.save!

        delete :destroy_systems, :organization_id => @org.label, :id => @host_collection.id
        must_respond_with(:success)
        HostCollection.where(:name => @host_collection.name).first.must_be_nil
      end
    end

    describe "PUT update_systems" do
      let(:action) { :update_systems }
      let(:content_view) { create(:content_view, :organization => @org) }
      let(:attrs) do
        { "content_view_id" => content_view.id.to_s, "environment_id" => @environment.id.to_s }
      end
      let(:req) do
        put action, id: @host_collection.id, organization_id: @org.label, host_collection: attrs
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :host_collections, @host_collection.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should complete successfully" do
        HostCollection.stubs(:where).returns(stub(:first => @host_collection))
        @host_collection.stubs(:systems).returns([@system])
        @system.expects(:update_attributes!).with(attrs).returns(true)

        put action, id: @host_collection.id, organization_id: @org.label, host_collection: attrs
        must_respond_with(:success)
      end
    end
  end

  end
end
end
