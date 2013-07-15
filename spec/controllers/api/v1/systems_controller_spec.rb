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

require 'spec_helper.rb'
require 'helpers/system_test_data.rb'
include OrchestrationHelper
include SystemHelperMethods

describe Api::V1::SystemsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods

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
  let(:user_without_update_permissions) { user_without_permissions }
  let(:user_with_destroy_permissions) { user_with_permissions { |u| u.can([:delete_systems], :organizations, nil, @organization) } }
  let(:user_without_destroy_permissions) { user_with_permissions { |u| u.can([:read_systems], :organizations, nil, @organization) } }
  let(:user_with_register_permissions) { user_with_permissions { |u| u.can([:register_systems], :organizations, nil, @organization) } }
  let(:user_without_register_permissions) { user_with_permissions { |u| u.can([:read_systems], :organizations, nil, @organization) } }

  before (:each) do
    set_default_locale
    disable_org_orchestration
    disable_consumer_group_orchestration
    disable_system_orchestration

    System.stub(:index).and_return(stub.as_null_object)

    Resources::Candlepin::Consumer.stub!(:create).and_return({ :uuid => uuid, :owner => { :key => uuid } })
    Resources::Candlepin::Consumer.stub!(:update).and_return(true)
    Resources::Candlepin::Consumer.stub!(:available_pools).and_return([])

    if Katello.config.katello?
      Runcible::Extensions::Consumer.stub!(:create).and_return({ :id => uuid })
      Runcible::Extensions::Consumer.stub!(:update).and_return(true)
    end

    @organization  = Organization.create!(:name => 'test_org', :label => 'test_org')
    @environment_1 = KTEnvironment.create!(:name => 'test_1', :label => 'test_1', :prior => @organization.library.id, :organization => @organization)

    @system_group_1 = SystemGroup.create!(:name => 'System Group 1', :organization_id => @organization.id)
    @system_group_2 = SystemGroup.create!(:name => 'System Group 2', :description => "fake description", :organization => @organization)

    login_user_api.stub(:default_environment).and_return(nil)
  end

  describe "create a system" do

    let(:action) { :create }
    let(:req) { post :create, :owner => @organization.name, :environment_id => @environment_1.id, :name => 'test', :cp_type => 'system', :facts => facts }
    let(:authorized_user) { user_with_create_permissions }
    let(:unauthorized_user) { user_without_create_permissions }
    it_should_behave_like "protected action"

    it "requires either environment_id, owner, or organization_id to be specified" do
      post :create
      response.code.should == "404"
    end

    it "sets installed products to the consumer" do
      System.should_receive(:create!).with(hash_including(:environment => @environment_1, :cp_type => 'system', :installedProducts => installed_products, :name => 'test')).once.and_return({})
      post :create, :organization_id => @organization.name, :environment_id => @environment_1.id, :name => 'test', :cp_type => 'system', :installedProducts => installed_products
    end

    it "sets the content view" do
      view = create(:content_view)
      ContentView.stub(:readable).and_return(ContentView)
      System.should_receive(:create!).with(hash_including(content_view: view, environment: @environment_1, cp_type: "system", name: "test"))
      post :create, :organization_id => @organization.name, :environment_id => @environment_1.id, :name => 'test', :cp_type => 'system',
        :content_view_id => view.id
    end

    it "should refresh ES index" do
      System.index.should_receive(:refresh)
      System.stub(:create!).and_return({})
      post :create, :organization_id => @organization.name, :environment_id => @environment_1.id, :name => 'test', :cp_type => 'system', :installedProducts => installed_products
    end

    context "in organization with one environment" do
      it "requires either organization_id" do
        System.should_receive(:create!).with(hash_including(:environment => @environment_1, :cp_type => 'system', :facts => facts, :name => 'test')).once.and_return({})
        post :create, :organization_id => @organization.name, :environment_id => @environment_1.id, :name => 'test', :cp_type => 'system', :facts => facts
      end

      it "or requires owner (key)" do
        System.should_receive(:create!).with(hash_including(:environment => @environment_1, :cp_type => 'system', :facts => facts, :name => 'test')).once.and_return({})
        post :create, :owner => @organization.name, :environment_id => @environment_1.id, :name => 'test', :cp_type => 'system', :facts => facts
      end
    end

    context "in organization with multiple environments" do
      before(:each) do
        @environment_2 = KTEnvironment.new(:name => 'test_2', :label => 'test_2', :prior => @environment_1, :organization => @organization)
        @environment_2.save!
      end

      it "requires environment id" do
        System.should_receive(:create!).with(hash_including('environment' => @environment_1, 'cp_type' => 'system', 'facts' => facts, 'name' => 'test')).once.and_return({})
        post :create, :environment_id => @environment_1.id, :name => 'test', :cp_type => 'system', :facts => facts
      end

      it "fails if no environment_id was specified" do
        post :create, :organization_id => @organization.label
        response.code.should == "400"
      end
    end

    context "with environment_id containing environment-content_view" do
      it "assigns the system to the environment and view" do
        view           = ContentView.create(:name => 'test view', :label => 'test_view', :organization => @organization)
        environment_id = @environment_1.id.to_s + '-' + view.id.to_s

        System.should_receive(:create!).with(hash_including(:environment  => @environment_1,
                                                            :content_view => view,
                                                            :cp_type      => 'system', :facts => facts,
                                                            :name         => 'test')).once.and_return({})

        post :create, :organization_id => @organization.name, :environment_id => environment_id,
             :name                     => 'test', :cp_type => 'system', :facts => facts
      end
    end

    context "when activation keys are provided" do

      before(:each) do
        @activation_key_1 = ActivationKey.create!(:environment   => @environment_1,
                                                  :organization  => @organization,
                                                  :name          => "activation_key_1",
                                                  :system_groups => [@system_group_1], :user => @user)
        @activation_key_2 = ActivationKey.create!(:environment   => @environment_1, :organization => @organization, :name => "activation_key_2",
                                                  :system_groups => [@system_group_2])

        @activation_key_1.stub(:subscribe_system).and_return()
        @activation_key_2.stub(:subscribe_system).and_return()
        @activation_key_1.stub(:apply_to_system).and_return()
        @activation_key_2.stub(:apply_to_system).and_return()

        @system_data = {
            :name            => "Test System 1",
            :facts           => facts,
            :environment_id  => @environment_1.id,
            :cp_type         => "system",
            :organization_id => @organization.label,
            :activation_keys => "#{@activation_key_1.name},#{@activation_key_2.name}"
        }
      end

      context "and they are correct" do

        before(:each) do
          @controller.stub(:find_activation_keys).and_return([@activation_key_1, @activation_key_2])
        end

        it "uses user credentials of the hidden user" do
          User.should_receive("current=").at_least(:once)
          post :activate, @system_data
          response.should be_success
        end

        it "sets the environment according the activation keys" do
          @activation_key_2.should_receive(:apply_to_system)
          @activation_key_1.should_receive(:apply_to_system)
          post :activate, @system_data
          response.should be_success
        end

        it "should subscribe the system according to activation keys" do
          @activation_key_1.should_receive(:subscribe_system)
          @activation_key_2.should_receive(:subscribe_system)
          post :activate, @system_data
          response.should be_success
        end

        it "should add the system to all system groups associated to activation keys" do
          post :activate, @system_data
          response.should be_success
          System.last.system_group_ids.should include(@system_group_1.id)
          System.last.system_group_ids.should include(@system_group_2.id)
        end

        it "should set the system's content view to the key's view" do
          @activation_key_3 = ActivationKey.create!(:environment   => @environment_1, :organization => @organization, :name => "activation_key_3",
                                                    :system_groups => [@system_group_2])
          @controller.stub(:find_activation_keys).and_return([@activation_key_3])
          System.any_instance.stub(:facts).and_return(@system_data[:facts])

          content_view = FactoryGirl.build_stubbed(:content_view)
          @activation_key_3.stub(:content_view_id).and_return(content_view.id)
          ContentView.stub(:find).and_return(content_view)
          content_view.stub(:in_environment?).and_return(true)
          @system_data[:activation_keys] = [@activation_key_3.name]

          post :activate, @system_data
          response.should be_success
          System.last.content_view_id.should eql(content_view.id)
        end

        it "should refresh ES index" do
          System.index.should_receive(:refresh)
          post :activate, @system_data
        end
      end

      context "and they are not in the system" do
        it "set the environment according the activation keys" do
          post :activate, :organization_id => @organization.label, :activation_keys => "notInSystem"
          response.code.should == "404"
        end
      end
    end

  end

  it "returns 410 for deleted systems" do
    Resources::Candlepin::Consumer.should_receive(:get).and_return do
      raise RestClient::Gone.new(
                mock(:response, :code => 410, :body =>
                    '{"displayMessage":"Consumer 83705a61-8968-444f-9253-caefbc0e9995 has been deleted",' +
                        '"deletedId":"83705a61-8968-444f-9253-caefbc0e9995"}'))
    end

    get :show, :id => '83705a61-8968-444f-9253-caefbc0e9995'
    response.code.should == "410"
    response.headers['X-CANDLEPIN-VERSION'].should_not be_blank
  end

  describe "create a hypervisor" do

    before do
      User.stub(:consumer? => true)
    end

    let(:virt_who_params) { { "env" => @environment_1.name, "host2" => ["GUEST3", "GUEST4"], "owner" => @organization.name } }

    it "requires either environment_id, owner, or organization_id to be specified" do
      post :create
      response.code.should == "404"
    end

    it "creates hypervisor" do
      System.should_receive(:register_hypervisors).with(@environment_1, virt_who_params)
      post :hypervisors_update, virt_who_params
    end

    it "sends back candlepin response" do
      cp_response = { "created" => SystemTestData.new_hypervisor }
      System.stub(:register_hypervisors => [cp_response, []])
      post :hypervisors_update, virt_who_params
      JSON.parse(response.body).should == cp_response
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

      Resources::Candlepin::Consumer.stub(:get => SystemTestData.host)
    end

    let(:action) { :index }
    let(:req) { get :index, :owner => @organization.label }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "requires either organization_id, owner, or environment_id" do
      get :index
      response.code.should == "404"
    end

    it "should show all systems in the organization" do
      Glue::ElasticSearch::Items.any_instance.should_receive(:retrieve).and_return([[@system_1, @system_2], 2])

      get :index, :organization_id => @organization.label
      response.body.should be_json([@system_1, @system_2].to_json)
    end

    it "should show all systems for the owner" do
      Glue::ElasticSearch::Items.any_instance.should_receive(:retrieve).and_return([[@system_1, @system_2], 2])

      get :index, :owner => @organization.label
      response.body.should be_json([@system_1, @system_2].to_json)
    end

    it "should show only systems in the environment" do
      Glue::ElasticSearch::Items.any_instance.should_receive(:retrieve).and_return([[@system_1], 1])

      get :index, :environment_id => @environment_1.id
      response.body.should == [@system_1].to_json
    end

    context "with pool_id" do

      let(:pool_id) { "POOL_ID_123456" }

      before :each do
        Resources::Candlepin::Consumer.stub!(:create).and_return({ :uuid => uuid_3 })
        @system_3 = System.create!(:name => 'test3', :environment => @environment_2, :cp_type => 'system', :facts => facts)
        System.stub(:all_by_pool_uuid).and_return([@system_1.uuid, @system_3.uuid])
        Glue::ElasticSearch::Items.any_instance.should_receive(:retrieve).and_return([[@system_1, @system_3], 2])
      end

      it "should show all systems in the organization that are subscribed to a pool" do
        get :index, :organization_id => @organization.label, :pool_id => pool_id
        returned_uuids = JSON.parse(response.body).map { |sys| sys["uuid"] }

        response.should be_success
        returned_uuids.should include(@system_1.uuid, @system_3.uuid)
      end

      it "should show only systems in the environment that are subscribed to a pool" do
        get :index, :environment_id => @environment_2.id, :pool_id => pool_id
        returned_uuids = JSON.parse(response.body).map { |sys| sys["uuid"] }

        returned_uuids.should include(@system_3.uuid)
      end

    end

  end

  describe "upload package profile", :katello => true do

    before(:each) do
      @sys = System.new(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
      System.stub!(:first).and_return(@sys)
      @sys.stub(:guests => [])
    end

    let(:action) { :upload_package_profile }
    let(:req) { put :upload_package_profile, :id => uuid, :_json => package_profile[:profile] }

    context "update permissions" do
      let(:authorized_user) { user_with_update_permissions }
      let(:unauthorized_user) { user_without_update_permissions }
      it_should_behave_like "protected action"

      it "successfully with update permissions" do
        Runcible::Extensions::Consumer.should_receive(:upload_profile).once.with(uuid, 'rpm', package_profile[:profile]).and_return(true)
        put :upload_package_profile, :id => uuid, :_json => package_profile[:profile], :format => :json
        response.body.should == @sys.to_json
      end
    end

    context "update permissions" do
      let(:authorized_user) { user_with_register_permissions }
      let(:unauthorized_user) { user_without_register_permissions }
      it_should_behave_like "protected action"

      it "successfully with register permissions" do
        Runcible::Extensions::Consumer.should_receive(:upload_profile).once.with(uuid, 'rpm', package_profile[:profile]).and_return(true)
        put :upload_package_profile, :id => uuid, :_json => package_profile[:profile], :format => :json
        response.body.should == @sys.to_json
      end
    end
  end

  describe "view packages in a specific system" do

    before(:each) do
      @sys = System.new(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
      System.stub!(:first).and_return(@sys)
    end

    let(:action) { :package_profile }
    let(:req) { get :package_profile, :id => uuid }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "successfully" do
      @sys.should_receive(:simple_packages).once.and_return(package_profile[:profile])
      get :package_profile, :id => uuid
      response.body.should == sorted.to_json
      response.should be_success
    end
  end

  describe "update a system" do
    before(:each) do
      @sys           = System.create!(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid, :description => "fake description")
      @environment_2 = KTEnvironment.create!(:name => 'test_2', :label => 'test_2', :prior => @organization.library.id, :organization => @organization)
      Resources::Candlepin::Consumer.stub!(:get).and_return({ :uuid => uuid })
      System.stub!(:first).and_return(@sys)
    end

    let(:action) { :update }
    let(:req) { post :update, :id => uuid, :name => "foo_name" }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it "should change the name" do
      Runcible::Extensions::Consumer.should_receive(:update).once.with(uuid, { :display_name => "foo_name" }).and_return(true) if Katello.config.katello?
      put :update, :id => uuid, :name => "foo_name"
      response.body.should == @sys.to_json
      response.should be_success
    end

    it "should change the description" do
      Runcible::Extensions::Consumer.should_receive(:update).once.with(uuid, { :display_name => "test" }).and_return(true) if Katello.config.katello?
      put :update, :id => uuid, :description => "redkin is awesome."
      response.body.should == @sys.to_json
      response.should be_success
    end

    it "should change the location" do
      Runcible::Extensions::Consumer.should_receive(:update).once.with(uuid, { :display_name => "test" }).and_return(true) if Katello.config.katello?
      put :update, :id => uuid, :location => "never-neverland"
      response.body.should == @sys.to_json
      response.should be_success
    end

    it "should change the content view" do
      view = build_stubbed(:content_view)
      ContentView.stub_chain(:readable, :find_by_id).and_return(view)
      ContentView.stub(:find).and_return(view)
      view.stub(:in_environment?).and_return(true)
      put :update, id: uuid, content_view_id: view.id
      @sys.reload.content_view_id.should eql(view.id)
    end

    it "should update installed products" do
      @sys.facts = {}
      @sys.stub(:guest => 'false', :guests => [])
      Resources::Candlepin::Consumer.should_receive(:update).once.with(uuid, {}, nil, installed_products, nil, nil, nil, anything, nil).and_return(true)
      put :update, :id => uuid, :installedProducts => installed_products
      response.body.should == @sys.to_json
      response.should be_success
    end

    it "should update releaseVer" do
      @sys.facts = {}
      @sys.stub(:guest => 'false', :guests => [])
      Resources::Candlepin::Consumer.should_receive(:update).once.with(uuid, {}, nil, nil, nil, "1.1", nil, anything, nil).and_return(true)
      put :update, :id => uuid, :releaseVer => "1.1"
      response.body.should == @sys.to_json
      response.should be_success
    end

    it "should update service level agreement" do
      @sys.facts = {}
      @sys.stub(:guest => 'false', :guests => [])
      Resources::Candlepin::Consumer.should_receive(:update).once.with(uuid, {}, nil, nil, nil, nil, "SLA", anything, nil).and_return(true)
      put :update, :id => uuid, :serviceLevel => "SLA"
      response.body.should == @sys.to_json
      response.should be_success
    end

    it "should update environment" do
      @sys.facts = {}
      @sys.stub(:guest => 'false', :guests => [], :environment => @environment_2)
      Resources::Candlepin::Consumer.should_receive(:update).once.with(uuid, {}, nil, nil, nil, nil, nil, @environment_2.id, nil).and_return(true)
      put :update, :id => uuid, :environment_id => @environment_2.id
      response.body.should == @sys.to_json
      response.should be_success
    end

    it "should update capabilities" do
      @sys.capabilities = {:name => 'cores'}
      @sys.stub(:guest => 'false', :guests => [])
      Resources::Candlepin::Consumer.should_receive(:update).once.with(uuid, {"sockets" => 0}, nil, nil, nil, nil, nil, anything, {:name => "cores"}).and_return(true)
      put :update, :id => uuid, :environment_id => @environment_2.id
      response.body.should == @sys.to_json
      response.should be_success
    end

    it "should refresh ES index" do
      System.index.should_receive(:refresh)
      put :update, :id => uuid, :name => "foo_name"
    end

  end

  describe "add system groups to a system" do
    before(:each) do
      @system = System.create!(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid, :description => "fake description")
      Resources::Candlepin::Consumer.stub!(:get).and_return({ :uuid => uuid })
      System.stub!(:first).and_return(@system)
    end

    let(:action) { :add_system_groups }
    let(:req) { post :add_system_groups, :id => @system.uuid }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it "should update the system groups the system is in" do
      ids = [@system_group_1.id, @system_group_2.id]
      post :add_system_groups, :id => @system.uuid, :system => { :system_group_ids => ids }
      response.should be_success
      @system.system_group_ids.should include(@system_group_1.id)
      @system.system_group_ids.should include(@system_group_2.id)
    end

  end

  describe "remove system groups to a system" do
    before(:each) do
      @system = System.create!(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts,
                               :uuid => uuid, :description => "fake description", :system_group_ids => [@system_group_1.id, @system_group_2.id])
      Resources::Candlepin::Consumer.stub!(:get).and_return({ :uuid => uuid })
      System.stub!(:first).and_return(@system)
    end

    let(:action) { :add_system_groups }
    let(:req) { post :add_system_groups, :id => @system.uuid }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }
    it_should_behave_like "protected action"

    it "should update the system groups the system is in" do
      ids = [@system_group_1.id, @system_group_2.id]
      delete :remove_system_groups, :id => @system.uuid, :system => { :system_group_ids => ids }
      response.should be_success
      @system.reload.system_group_ids.should be_empty
    end

  end

  describe "list errata", :katello => true do
    before(:each) do
      @system = System.create(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
      System.stub!(:first).and_return(@system)
    end

    let(:action) { :errata }
    let(:req) { get :errata, :id => @system.uuid }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should find System" do
      System.should_receive(:first).once.with(hash_including(:conditions => { :uuid => @system.uuid })).and_return(@system)
      get :errata, :id => @system.uuid
    end

    it "should retrieve Consumer's errata from pulp" do
      Runcible::Extensions::Consumer.should_receive(:applicable_errata).with(@system.uuid)
      get :errata, :id => @system.uuid
    end
  end

  describe "list available pools" do
    before(:each) do
      @system = System.create(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
      System.stub!(:first).and_return(@system)
    end

    let(:action) { :pools }
    let(:req) { get :pools, :id => @system.uuid }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should find System" do
      System.should_receive(:first).once.with(hash_including(:conditions => { :uuid => @system.uuid })).and_return(@system)
      get :pools, :id => @system.uuid
    end

    it "should retrieve available pools from Candlepin" do
      #@system.should_receive(:available_pools_full).once.and_return([])
      Resources::Candlepin::Consumer.should_receive(:available_pools).once.with(@system.uuid, true).and_return([])
      get :pools, :id => @system.uuid
    end

    pending "should retrieve available pools from Candlepin, explicit match_system false" do
      #@system.should_receive(:available_pools_full).once.and_return([])
      Resources::Candlepin::Consumer.should_receive(:available_pools).once.with(@system.uuid, true).and_return([])
      get :pools, :id => @system.uuid, :match_system => true
    end

    pending "should retrieve available pools from Candlepin, explicit match_system true" do
      #@system.should_receive(:available_pools_full).once.and_return([])
      Resources::Candlepin::Consumer.should_receive(:available_pools).once.with(@system.uuid, true).and_return([])
      get :pools, :id => @system.uuid, :match_system => true
    end
  end

  describe "list available releases" do
    before(:each) do
      @system = System.create(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
      System.stub!(:first).and_return(@system)
    end

    let(:action) { :releases }
    let(:req) { get :releases, :id => @system.uuid }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should show releases that are available in given environment" do
      @system.should_receive(:available_releases).and_return(["6.1", "6.2", "6Server"])
      req
      JSON.parse(response.body).should == { "releases" => ["6.1", "6.2", "6Server"] }
    end
  end

  describe "update enabled_repos", :katello => true do
    before do
      User.stub(:consumer? => true)
      @system = System.create(:name => 'test', :environment => @environment_1, :cp_type => 'system', :facts => facts, :uuid => uuid)
      System.stub!(:first).and_return(@system)
      Repository.stub!(:where).with(:relative_path=>'foo').and_return([OpenStruct.new({ :pulp_id => 'a' })])
      Repository.stub!(:where).with(:relative_path=>'bar').and_return([OpenStruct.new({ :pulp_id => 'b' })])
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
      Runcible::Extensions::Consumer.should_receive(:retrieve_bindings).with(@system.uuid).once.and_return([{ 'repo_id' => 'a' }, { 'repo_id' => 'b' }])

      put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
      response.status.should == 200
    end

    it "should bind one" do
      Runcible::Extensions::Consumer.should_receive(:retrieve_bindings).with(@system.uuid).once.and_return([{ 'repo_id' => 'a' }])
      Runcible::Extensions::Consumer.should_receive(:bind_all).with(@system.uuid, 'b', false).once.and_return([])
      put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
      response.status.should == 200
    end

    it "should bind two" do
      Runcible::Extensions::Consumer.should_receive(:retrieve_bindings).with(@system.uuid).once.and_return({})
      Runcible::Extensions::Consumer.should_receive(:bind_all).with(@system.uuid, 'a', false).once.once.and_return([])
      Runcible::Extensions::Consumer.should_receive(:bind_all).with(@system.uuid, 'b', false).once.once.and_return([])
      put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
      response.status.should == 200
    end

    it "should bind one and unbind one" do
      Runcible::Extensions::Consumer.should_receive(:retrieve_bindings).with(@system.uuid).once.and_return([{ 'repo_id' => 'b' }, { 'repo_id' => 'c' }])
      Runcible::Extensions::Consumer.should_receive(:bind_all).with(@system.uuid, 'a', false).once.once.and_return([])
      Runcible::Extensions::Consumer.should_receive(:unbind_all).with(@system.uuid, 'c').once.and_return([])
      put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos
      response.status.should == 200
    end

    it "should unbind two" do
      Runcible::Extensions::Consumer.should_receive(:retrieve_bindings).with(@system.uuid).once.and_return([{ 'repo_id' => 'a' }, { 'repo_id' => 'b' }])
      Runcible::Extensions::Consumer.should_receive(:unbind_all).with(@system.uuid, 'a').once.once.and_return([])
      Runcible::Extensions::Consumer.should_receive(:unbind_all).with(@system.uuid, 'b').once.once.and_return([])
      put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos_empty
      response.status.should == 200
    end

    it "should do nothing" do
      Runcible::Extensions::Consumer.should_receive(:retrieve_bindings).with(@system.uuid).once.and_return({})
      put :enabled_repos, :id => @system.uuid, :enabled_repos => enabled_repos_empty
      response.status.should == 200
    end
  end
end
