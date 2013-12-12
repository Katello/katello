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
require 'helpers/system_test_data.rb'
module Katello
  describe Api::V1::SystemsController do
    include OrchestrationHelper
    include SystemHelperMethods
    include SystemHelperMethods
    include AuthorizationHelperMethods
    include OrganizationHelperMethods

    let(:facts) { { "distribution.name" => "Fedora", "cpu.cpu_socket(s)" => "2" } }
    let(:uuid) { '1234' }
    let(:package_profile) {
      { :profile =>
        [Glue::Pulp::SimplePackage.new({ "epoch" => 0, "name" => "im-chooser", "arch" => "x86_64", "version" => "1.4.0", "vendor" => "Fedora Project", "release" => "1.fc14" }),
         Glue::Pulp::SimplePackage.new({ "epoch" => 0, "name" => "maven-enforcer-api", "arch" => "noarch", "version" => "1.0", "vendor" => "Fedora Project", "release" => "0.1.b2.fc14" }),
         Glue::Pulp::SimplePackage.new({"epoch" => 0, "name" => "ppp", "arch" => "x86_64", "version" => "2.4.5", "vendor" => "Fedora Project", "release" => "12.fc14" })]
      }.with_indifferent_access
    }
    let(:installed_products) { [{ "productId" => "69", "productName" => "Red Hat Enterprise Linux Server" }] }
    let(:sorted) { package_profile[:profile].sort { |a, b| a.name.downcase <=> b.name.downcase } }

    let(:user_with_read_permissions) { user_with_permissions { |u| u.can(:read_systems, :organizations, nil, @organization) } }
    let(:user_without_read_permissions) { user_without_permissions }
    let(:user_with_create_permissions) { user_with_permissions { |u| u.can([:register_systems], :environments, @environment_1.id, @organization) } }
    let(:user_without_create_permissions) { user_with_permissions { |u| u.can(:read_systems, :organizations, nil, @organization) } }
    let(:user_with_update_permissions) { user_with_permissions { |u| u.can([:read_systems, :update_systems], :organizations, nil, @organization) } }
    let(:user_without_update_permissions) {  user_without_permissions }
    let(:user_with_destroy_permissions) { user_with_permissions { |u| u.can([:delete_systems], :organizations, nil, @organization) } }
    let(:user_without_destroy_permissions) { user_with_permissions { |u| u.can([:read_systems], :organizations, nil, @organization) } }
    let(:user_with_register_permissions) { user_with_permissions { |u| u.can([:register_systems], :organizations, nil, @organization) } }
    let(:user_without_register_permissions) { user_with_permissions { |u| u.can([:read_systems], :organizations, nil, @organization) } }

    before (:each) do
      setup_controller_defaults_api
      disable_org_orchestration
      disable_consumer_group_orchestration
      disable_system_orchestration

      System.stubs(:index).returns(stub())
      System.stubs(:prepopulate!).returns(true)
      System.any_instance.stubs(:update_system_groups)

      Resources::Candlepin::Consumer.stubs(:create).returns({ :uuid => uuid, :owner => { :key => uuid } })
      Resources::Candlepin::Consumer.stubs(:update).returns(true)
      Resources::Candlepin::Consumer.stubs(:available_pools).returns([])

      if Katello.config.katello?
        pulp_server = Katello.pulp_server
        Katello.stubs(:pulp_server).returns(pulp_server)
        Katello.pulp_server.extensions.consumer.stubs(:create).returns({ :id => uuid })
        Katello.pulp_server.extensions.consumer.stubs(:regenerate_applicability).returns(TaskStatus.new)
        Katello.pulp_server.extensions.consumer.stubs(:regenerate_applicability_by_ids).returns(TaskStatus.new)
      end

      System.any_instance.stubs(:consumer_as_json).returns({})

      @organization  = Organization.create!(:name => 'test_org', :label => 'test_org')
      if Katello.config.katello?
        @environment_1 = create_environment(:name => 'test_1', :label => 'test_1', :prior => @organization.library.id, :organization => @organization)
      else
        @environment_1 = @organization.library
      end

      @cv = @environment_1.content_views.first
      @cve = ContentViewEnvironment.where(:content_view_id => @cv.id, :environment_id => @environment_1.id).first

      @system_group_1 = SystemGroup.create!(:name => 'System Group 1', :organization_id => @organization.id)
      @system_group_2 = SystemGroup.create!(:name => 'System Group 2', :description => "fake description", :organization => @organization)

      ContentView.stubs(:readable).returns(stub(:find_by_id => @cv))
    end

    describe "create a system" do
      it "requires either environment_id, owner, or organization_id to be specified" do
        post :create
        response.code.must_equal "404"
      end

      it "sets installed products to the consumer" do
        System.expects(:create!).with(has_entries("environment" => @environment_1, "content_view" => @cv,
                                                  "cp_type" => 'system', "installedProducts" => installed_products, "name" => 'test')).once.returns({})

        post :create, :organization_id => @organization.name, :environment_id => @cve.cp_id,
          :name => 'test', :cp_type => 'system', :installedProducts => installed_products
      end

      it "sets the content view" do
        System.expects(:create!).with(has_entries("content_view" => @cv, "environment" => @environment_1, "cp_type" => "system", "name" => "test"))
        post :create, :organization_id => @organization.name, :environment_id => @environment_1.id, :name => 'test', :cp_type => 'system',
          :content_view_id => @cv.id
      end

      context "in organization with one environment" do
        it "requires either organization_id" do
          System.expects(:create!).with(has_entries("environment" => @environment_1, "cp_type" => 'system', "facts" => facts, "name" => 'test')).once.returns({})
          post :create, :organization_id => @organization.name, :environment_id => @cve.cp_id, :name => 'test', :cp_type => 'system', :facts => facts
        end

        it "or requires owner (key)" do
          System.expects(:create!).with(has_entries("environment" => @environment_1, "cp_type" => 'system', "facts" => facts, "name" => 'test')).once.returns({})
          post :create, :owner => @organization.name, :environment_id => @cve.cp_id, :name => 'test', :cp_type => 'system', :facts => facts
        end
      end

      context "in organization with multiple environments (katello)" do
        it "requires environment id" do
          cv = @environment_1.content_views.first
          cve = ContentViewEnvironment.where(:content_view_id => cv.id, :environment_id => @environment_1.id).first

          System.expects(:create!).with(has_entries('environment' => @environment_1, 'cp_type' => 'system', 'facts' => facts, 'name' => 'test')).once.returns({})
          post :create, :environment_id => cve.cp_id, :name => 'test', :cp_type => 'system', :facts => facts
        end

        it "fails if no environment_id was specified" do
          post :create, :organization_id => @organization.label
          response.code.must_equal "400"
        end
      end

      context "with environment_id containing environment-content_view" do
        it "assigns the system to the environment and view" do
          view = @environment_1.content_views.first
          cve = ContentViewEnvironment.where(:content_view_id => view.id, :environment_id => @environment_1.id).first
          System.expects(:create!).with(has_entries("environment"  => @environment_1,
                                                    "content_view" => view,
                                                    "cp_type"      => 'system', "facts" => facts,
                                                    "name"         => 'test')).once.returns({})

          post :create, :organization_id => @organization.name, :environment_id => cve.cp_id,
            :name                     => 'test', :cp_type => 'system', :facts => facts
        end
      end


      before(:each) do
        @activation_key_1 = create_activation_key(:environment   => @environment_1,
                                                  :organization  => @organization,
                                                  :name          => "activation_key_1",
                                                  :system_groups => [@system_group_1], :user => @user)
        @activation_key_2 = create_activation_key(:environment   => @environment_1, :organization => @organization, :name => "activation_key_2",
                                                  :system_groups => [@system_group_2])

        @activation_key_1.stubs(:subscribe_system).returns()
        @activation_key_2.stubs(:subscribe_system).returns()
        @activation_key_1.stubs(:apply_to_system).returns()
        @activation_key_2.stubs(:apply_to_system).returns()

        @system_data = {
          :name            => "Test System 1",
          :facts           => facts,
          :environment_id  => @environment_1.id,
          :content_view_id => @environment_1.content_views.first,
          :cp_type         => "system",
          :organization_id => @organization.label,
          :activation_keys => "#{@activation_key_1.name},#{@activation_key_2.name}"
        }
      end

      context "and they are correct" do

        before(:each) do
          @controller.stubs(:find_activation_keys).returns([@activation_key_1, @activation_key_2])
          User.stubs(:hidden).returns(stub(:first => User.current))
        end

        it "uses user credentials of the hidden user" do
          User.expects("current=").at_least_once
          post :activate, @system_data
          must_respond_with(:success)
        end

        it "sets the environment according the activation keys" do
          @activation_key_2.expects(:apply_to_system)
          @activation_key_1.expects(:apply_to_system)
          post :activate, @system_data
          must_respond_with(:success)
        end

        it "should subscribe the system according to activation keys" do
          @activation_key_1.expects(:subscribe_system)
          @activation_key_2.expects(:subscribe_system)
          post :activate, @system_data
          must_respond_with(:success)
        end

        it "should add the system to all system groups associated to activation keys" do
          post :activate, @system_data
          must_respond_with(:success)
          System.last.system_group_ids.must_include(@system_group_1.id)
          System.last.system_group_ids.must_include(@system_group_2.id)
        end

        it "should set the system's content view to the key's view" do
          @activation_key_3 = create_activation_key(:environment => @environment_1,
                                                    :content_view => @environment_1.default_content_view,
                                                    :organization => @organization, :name => "activation_key_3",
                                                    :system_groups => [@system_group_2])
          @controller.stubs(:find_activation_keys).returns([@activation_key_3])
          System.any_instance.stubs(:facts).returns(@system_data[:facts])

          content_view = FactoryGirl.build_stubbed(:content_view)
          ContentView.stubs(:find).returns(content_view)
          content_view.stubs(:in_environment?).returns(true)
          @system_data[:activation_keys] = [@activation_key_3.name]

          post :activate, @system_data
          must_respond_with(:success)
          System.last.content_view_id.must_equal(@activation_key_3.content_view.id)
        end

      end

      context "and they are not in the system" do
        it "set the environment according the activation keys" do
          post :activate, :organization_id => @organization.label, :activation_keys => "notInSystem"
          response.code.must_equal "404"
        end
      end
    end

    it "returns 410 for deleted systems" do
      exception_response  = OpenStruct.new(:code => 410, :body =>
                                           '{"displayMessage":"Consumer 83705a61-8968-444f-9253-caefbc0e9995 has been deleted",' +
                                             '"deletedId":"83705a61-8968-444f-9253-caefbc0e9995"}')
      Resources::Candlepin::Consumer.expects(:get).at_least_once.raises(RestClient::Gone.new(exception_response))

      get :show, :id => '83705a61-8968-444f-9253-caefbc0e9995'
      response.code.must_equal "410"
      response.headers['X-CANDLEPIN-VERSION'].wont_be :blank?
    end

    describe "create a hypervisor" do

      before do
        User.stubs(:consumer? => true)
      end

      let(:virt_who_params) do
        cv = @environment_1.content_views.first
        cve = ContentViewEnvironment.where(:content_view_id => cv.id, :environment_id => @environment_1.id).first
        { "env" => cve.label,
          "host2" => ["GUEST3", "GUEST4"], "owner" => @organization.name }
      end

      it "requires either environment_id, owner, or organization_id to be specified" do
        post :create
        response.code.must_equal "404"
      end

      it "creates hypervisor" do
        System.expects(:register_hypervisors).with(@environment_1, @environment_1.content_views.first, virt_who_params)
        post :hypervisors_update, virt_who_params
      end

      it "sends back candlepin response" do
        cp_response = { "created" => SystemTestData.new_hypervisor }
        System.stubs(:register_hypervisors => [cp_response, []])
        post :hypervisors_update, virt_who_params
        JSON.parse(response.body).must_equal cp_response
      end
    end

    describe "list systems" do

      let(:uuid_1) { "abc" }
      let(:uuid_2) { "def" }
      let(:uuid_3) { "ghi" }

      before(:each) do
        @environment_2 = KTEnvironment.new(:name => 'test_2', :label => 'test_2', :prior => @environment_1, :organization => @organization)
        @environment_2.save!

        @system_1 = create_system(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid_1)
        @system_2 = create_system(:name => 'test2', :environment => @environment_2, :cp_type => 'system', :facts => facts, :uuid => uuid_2)

        Resources::Candlepin::Consumer.stubs(:get => SystemTestData.host)
      end

      let(:action) { :index }
      let(:req) { get :index, :owner => @organization.label }
      let(:authorized_user) { user_with_read_permissions }
      let(:unauthorized_user) { user_without_read_permissions }
      it_should_behave_like "protected action"

      it "requires either organization_id, owner, or environment_id" do
        get :index
        response.code.must_equal "404"
      end

      it "should show all systems in the organization" do
        Glue::ElasticSearch::Items.any_instance.expects(:retrieve).returns([[@system_1, @system_2], 2])

        get :index, :organization_id => @organization.label
        response.body.must_equal([@system_1, @system_2].to_json)
      end

      it "should show all systems for the owner" do
        Glue::ElasticSearch::Items.any_instance.expects(:retrieve).returns([[@system_1, @system_2], 2])

        get :index, :owner => @organization.label
        response.body.must_equal([@system_1, @system_2].to_json)
      end

      it "should show only systems in the environment" do
        Glue::ElasticSearch::Items.any_instance.expects(:retrieve).returns([[@system_1], 1])

        get :index, :environment_id => @environment_1.id
        response.body.must_equal [@system_1].to_json
      end

      context "with pool_id" do

        let(:pool_id) { "POOL_ID_123456" }

        before :each do
          Resources::Candlepin::Consumer.stubs(:create).returns({ :uuid => uuid_3 })
          @system_3 = create_system(:name => 'test3', :environment => @environment_2, :cp_type => 'system', :facts => facts)
          System.stubs(:all_by_pool_uuid).returns([@system_1.uuid, @system_3.uuid])
          Glue::ElasticSearch::Items.any_instance.expects(:retrieve).returns([[@system_1, @system_3], 2])
        end

        it "should show all systems in the organization that are subscribed to a pool" do
          get :index, :organization_id => @organization.label, :pool_id => pool_id
          returned_uuids = JSON.parse(response.body).map { |sys| sys["uuid"] }

          must_respond_with(:success)
          returned_uuids.must_include(@system_1.uuid, @system_3.uuid)
        end

        it "should show only systems in the environment that are subscribed to a pool" do
          get :index, :environment_id => @environment_2.id, :pool_id => pool_id
          returned_uuids = JSON.parse(response.body).map { |sys| sys["uuid"] }

          returned_uuids.must_include(@system_3.uuid)
        end

      end

    end

    describe "upload package profil (katello)" do

      before(:each) do
        @sys = System.new(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
        System.stubs(:first).returns(@sys)
        @sys.stubs(:guests => [])
      end

      let(:action) { :upload_package_profile }
      let(:req) { put :upload_package_profile, :id => uuid, :_json => package_profile[:profile] }

      context "update permissions" do
        let(:authorized_user) { user_with_update_permissions }
        it_should_behave_like "protected action"

        it "successfully with update permissions" do
          Katello.pulp_server.extensions.consumer.expects(:upload_profile).once.with(uuid, 'rpm', package_profile[:profile]).returns(true)
          put :upload_package_profile, :id => uuid, :_json => package_profile[:profile], :format => :json
          response.body.must_equal @sys.to_json
        end
      end

      context "update permissions ignored on users without permission" do
        let(:authorized_user) { user_without_update_permissions }
        let(:action) {:upload_package_profile}
        it_should_behave_like "protected action"

        it "Don't successfully with update permissions" do
          User.current = user_without_update_permissions
          #unauthorized user, shouldn't talk to pulp and should return nothing
          Katello.pulp_server.extensions.consumer.expects(:upload_profile).never
          put :upload_package_profile, :id => uuid, :_json => package_profile[:profile], :format => :json
          response.body.must_equal({}.to_json)
        end
      end

      context "update permissions" do
        let(:authorized_user) { user_with_register_permissions }
        it_should_behave_like "protected action"

        it "successfully with register permissions" do
          Katello.pulp_server.extensions.consumer.expects(:upload_profile).once.with(uuid, 'rpm', package_profile[:profile]).returns(true)
          put :upload_package_profile, :id => uuid, :_json => package_profile[:profile], :format => :json
          response.body.must_equal @sys.to_json
        end
      end
    end

    describe "view packages in a specific system" do

      before(:each) do
        @sys = System.new(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
        System.stubs(:first).returns(@sys)
      end

      let(:action) { :package_profile }
      let(:req) { get :package_profile, :id => uuid }
      let(:authorized_user) { user_with_read_permissions }
      let(:unauthorized_user) { user_without_read_permissions }
      it_should_behave_like "protected action"

      it "successfully" do
        @sys.expects(:simple_packages).once.returns(package_profile[:profile])
        get :package_profile, :id => uuid
        response.body.must_equal sorted.to_json
        must_respond_with(:success)
      end
    end

    describe "update a system" do
      before(:each) do
        @sys           = create_system(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid, :description => "fake description")
        @environment_2 = create_environment(:name => 'test_2', :label => 'test_2', :prior => @organization.library.id, :organization => @organization)
        Resources::Candlepin::Consumer.stubs(:get).returns({ :uuid => uuid })
        System.stubs(:first).returns(@sys)
      end

      let(:action) { :update }
      let(:req) { post :update, :id => uuid, :name => "foo_name" }
      let(:authorized_user) { user_with_update_permissions }
      let(:unauthorized_user) { user_without_update_permissions }
      it_should_behave_like "protected action"

      it "should change the name" do
        Katello.pulp_server.extensions.consumer.expects(:update).once.with(uuid, { :display_name => "foo_name" }).returns(true) if Katello.config.katello?
        put :update, :id => uuid, :name => "foo_name"
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

      it "should change the description" do
        Katello.pulp_server.extensions.consumer.expects(:update).once.with(uuid, { :display_name => "test" }).returns(true) if Katello.config.katello?
        put :update, :id => uuid, :description => "redkin is awesome."
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

      it "should change the location" do
        Katello.pulp_server.extensions.consumer.expects(:update).once.with(uuid, { :display_name => "test" }).returns(true) if Katello.config.katello?
        put :update, :id => uuid, :location => "never-neverland"
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

      it "should change the content view (katello)" do
        promote_content_view(@sys.content_view, @environment_1, @environment_2)
        view = @sys.content_view
        put :update, id: uuid, content_view_id: view.id
        @sys.reload.content_view_id.must_equal(view.id)
      end

      it "should update installed products" do
        @sys.facts = {}
        System.any_instance.stubs(:guest).returns('false')
        System.any_instance.stubs(:guests).returns([])
        Resources::Candlepin::Consumer.expects(:update).once.with(uuid, {}, nil, installed_products, nil, nil, nil, anything, nil, nil).returns(true)
        put :update, :id => uuid, :installedProducts => installed_products
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

      it "should update releaseVer" do
        @sys.facts = {}
        System.any_instance.stubs(:guest).returns('false')
        System.any_instance.stubs(:guests).returns([])
        Resources::Candlepin::Consumer.expects(:update).once.with(uuid, {}, nil, nil, nil, "1.1", nil, anything, nil, nil).returns(true)
        put :update, :id => uuid, :releaseVer => "1.1"
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

      it "should update lastCheckin" do
        @sys.facts = {}
        System.any_instance.stubs(:guest).returns('false')
        System.any_instance.stubs(:guests).returns([])
        timestamp = 3.days.ago
        Resources::Candlepin::Consumer.expects(:update).once.with(uuid, {}, nil, nil, nil, nil, nil, anything, nil, timestamp.strftime('%F %T')).returns(true)

        put :update, :id => uuid, :lastCheckin => timestamp.strftime('%F %T')
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

      it "should update service level agreement" do
        @sys.facts = {}
        System.any_instance.stubs(:guest).returns('false')
        System.any_instance.stubs(:guests).returns([])
        Resources::Candlepin::Consumer.expects(:update).once.with(uuid, {}, nil, nil, nil, nil, "SLA", anything, nil, nil).returns(true)
        put :update, :id => uuid, :serviceLevel => "SLA"
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

      it "should update environment (katello)" do
        promote_content_view(@sys.content_view, @environment_1, @environment_2)
        @sys.facts = {}
        System.any_instance.stubs(:guest).returns('false')
        System.any_instance.stubs(:guests).returns([])
        System.any_instance.stubs(:regenerate_applicability).returns(TaskStatus.new)
        Resources::Candlepin::Consumer.expects(:update).once.with(uuid, {}, nil, nil, nil, nil, nil,
                                                                  "#{@environment_2.id}-#{@sys.content_view.id}", nil, nil).returns(true)
        System.any_instance.expects(:update_pulp_consumer).returns(true)
        put :update, :id => uuid, :environment_id => @environment_2.id
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

      it "handle memory as int" do
        @sys.facts = {'memory.memtotal' => 20000}
        System.any_instance.stubs(:guest).returns('false')
        System.any_instance.stubs(:guests).returns([])
        Resources::Candlepin::Consumer.expects(:update).once.with(uuid, {'memory.memtotal' => 20000}, nil,
                                                                  nil, nil, nil, nil, anything, nil, nil).returns(true)
        put :update, :id => uuid
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

      it "should update capabilities (katello)"  do
        promote_content_view(@sys.content_view, @environment_1, @environment_2)
        @sys.capabilities = {:name => 'cores'}
        System.any_instance.stubs(:guest).returns('false')
        Resources::Candlepin::Consumer.expects(:update).once.with(uuid, {"sockets" => 0}, nil, nil, nil, nil, nil, anything, {:name => "cores"}, nil).returns(true)
        System.any_instance.expects(:update_pulp_consumer).returns(true)

        put :update, :id => uuid, :environment_id => @environment_2.id
        response.body.must_equal @sys.to_json
        must_respond_with(:success)
      end

    end

    describe "add system groups to a system" do
      before(:each) do
        @system = create_system(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid, :description => "fake description")
        Resources::Candlepin::Consumer.stubs(:get).returns({ :uuid => uuid })
        System.stubs(:first).returns(@system)
      end

      let(:action) { :add_system_groups }
      let(:req) { post :add_system_groups, :id => @system.uuid }
      let(:authorized_user) { user_with_update_permissions }
      let(:unauthorized_user) { user_without_update_permissions }
      it_should_behave_like "protected action"

      it "should update the system groups the system is in" do
        ids = [@system_group_1.id, @system_group_2.id]
        post :add_system_groups, :id => @system.uuid, :system => { :system_group_ids => ids }
        must_respond_with(:success)
        @system.system_group_ids.must_include(@system_group_1.id)
        @system.system_group_ids.must_include(@system_group_2.id)
      end

    end

    describe "remove system groups to a system" do
      before(:each) do
        @system = create_system(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts,
                                :uuid => uuid, :description => "fake description", :system_group_ids => [@system_group_1.id, @system_group_2.id])
        Resources::Candlepin::Consumer.stubs(:get).returns({ :uuid => uuid })
        System.stubs(:first).returns(@system)
      end

      let(:action) { :add_system_groups }
      let(:req) { post :add_system_groups, :id => @system.uuid }
      let(:authorized_user) { user_with_update_permissions }
      let(:unauthorized_user) { user_without_update_permissions }
      it_should_behave_like "protected action"

      it "should update the system groups the system is in" do
        ids = [@system_group_1.id, @system_group_2.id]
        delete :remove_system_groups, :id => @system.uuid, :system => { :system_group_ids => ids }
        must_respond_with(:success)
        @system.reload.system_group_ids.must_be_empty
      end

    end

    describe "list errata (katello)" do
      before(:each) do
        @system = create_system(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
        System.stubs(:first).returns(@system)
      end

      let(:action) { :errata }
      let(:req) { get :errata, :id => @system.uuid }
      let(:authorized_user) { user_with_read_permissions }
      let(:unauthorized_user) { user_without_read_permissions }
      it_should_behave_like "protected action"

      it "should find System" do
        System.expects(:first).once.with(has_entries(:conditions => { :uuid => @system.uuid })).returns(@system)
        get :errata, :id => @system.uuid
      end

      it "should retrieve Consumer's errata from pulp" do
        Katello.pulp_server.extensions.consumer.expects(:applicable_errata).with([@system.uuid]).returns([])
        get :errata, :id => @system.uuid
      end
    end

    describe "list available pools" do
      before(:each) do
        @system = create_system(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
        System.stubs(:first).returns(@system)
      end

      let(:action) { :pools }
      let(:req) { get :pools, :id => @system.uuid }
      let(:authorized_user) { user_with_read_permissions }
      let(:unauthorized_user) { user_without_read_permissions }
      it_should_behave_like "protected action"

      it "should find System" do
        System.expects(:first).once.with(has_entries(:conditions => { :uuid => @system.uuid })).returns(@system)
        get :pools, :id => @system.uuid
      end

      it "should retrieve available pools from Candlepin" do
        #@system.expects(:available_pools_full).once.returns([])
        Resources::Candlepin::Consumer.expects(:available_pools).once.with(@system.uuid, true).returns([])
        get :pools, :id => @system.uuid
      end

      it "should retrieve available pools from Candlepin, explicit match_system false" do
        skip ""
        #@system.expects(:available_pools_full).once.returns([])
        Resources::Candlepin::Consumer.expects(:available_pools).once.with(@system.uuid, true).returns([])
        get :pools, :id => @system.uuid, :match_system => true
      end

      it "should retrieve available pools from Candlepin, explicit match_system true" do
        skip ""
        #@system.expects(:available_pools_full).once.returns([])
        Resources::Candlepin::Consumer.expects(:available_pools).once.with(@system.uuid, true).returns([])
        get :pools, :id => @system.uuid, :match_system => true
      end
    end

    describe "list available releases" do
      before(:each) do
        @system = create_system(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
        System.stubs(:first).returns(@system)
      end

      let(:action) { :releases }
      let(:req) { get :releases, :id => @system.uuid }
      let(:authorized_user) { user_with_read_permissions }
      let(:unauthorized_user) { user_without_read_permissions }
      it_should_behave_like "protected action"

      it "should show releases that are available in given environment" do
        @system.expects(:available_releases).returns(["6.1", "6.2", "6Server"])
        req
        JSON.parse(response.body).must_equal({ "releases" => ["6.1", "6.2", "6Server"] })
      end
    end

    describe "update enabled_repos (katello)" do
      before do
        User.stubs(:consumer? => true)
        @system = create_system(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
        System.stubs(:first).returns(@system)
        Repository.stubs(:where).with(:relative_path=>'foo').returns([OpenStruct.new({ :pulp_id => 'a' })])
        Repository.stubs(:where).with(:relative_path=>'bar').returns([OpenStruct.new({ :pulp_id => 'b' })])
      end
      let(:enabled_repos) {
        {
          "repos" => [
            {
              "baseurl" => ["https://hostname/pulp/repos/foo"],
            },
            {
              "baseurl" => ["https://hostname/pulp/repos/bar"],
            },
          ]
        }
      }
      let(:enabled_repos_empty) { { "repos" => [] } }

      it "should not bind any" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).once.returns(
          [{ 'repo_id' => 'a', 'type_id' =>'yum_distributor'  }, { 'repo_id' => 'b', 'type_id' => 'yum_distributor'}])

        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
        response.status.must_equal 200
      end

      it "should bind one" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).once.returns(
          [{ 'repo_id' => 'a', 'type_id' => 'yum_distributor' }])
        Katello.pulp_server.extensions.consumer.expects(:bind_all).with(@system.uuid, 'b', "yum_distributor", {:notify_agent=>false}).once.returns([])
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
        response.status.must_equal 200
      end

      it "should bind two" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).once.returns({})
        Katello.pulp_server.extensions.consumer.expects(:bind_all).with(@system.uuid, 'a', "yum_distributor", {:notify_agent=>false}).once.once.returns([])
        Katello.pulp_server.extensions.consumer.expects(:bind_all).with(@system.uuid, 'b', "yum_distributor", {:notify_agent=>false}).once.once.returns([])
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
        response.status.must_equal 200
      end

      it "should bind one and unbind one" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).once.returns(
          [{ 'repo_id' => 'b', 'type_id' =>'yum_distributor'  }, { 'repo_id' => 'c', 'type_id' =>'yum_distributor'  }])
        Katello.pulp_server.extensions.consumer.expects(:bind_all).with(@system.uuid, 'a', "yum_distributor", {:notify_agent=>false}).once.once.returns([])
        Katello.pulp_server.extensions.consumer.expects(:unbind_all).with(@system.uuid, 'c', 'yum_distributor').once.returns([])
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
        response.status.must_equal 200
      end

      it "should unbind two" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).once.returns(
          [{ 'repo_id' => 'a', 'type_id' =>'yum_distributor'  }, { 'repo_id' => 'b', 'type_id' =>'yum_distributor'  }])
        Katello.pulp_server.extensions.consumer.expects(:unbind_all).with(@system.uuid, 'a', 'yum_distributor').once.once.returns([])
        Katello.pulp_server.extensions.consumer.expects(:unbind_all).with(@system.uuid, 'b', 'yum_distributor').once.once.returns([])
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos_empty
        response.status.must_equal 200
      end

      it "should do nothing" do
        Katello.pulp_server.extensions.consumer.expects(:retrieve_bindings).with(@system.uuid).once.returns({})
        put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos_empty
        response.status.must_equal 200
      end
    end
  end
end
