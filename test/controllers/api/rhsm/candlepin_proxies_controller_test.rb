# encoding: utf-8

require "katello_test_helper"

module Katello
  describe Api::Rhsm::CandlepinProxiesController do
    include Support::ForemanTasks::Task

    before do
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @system = katello_systems(:simple_server)

      @host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @system.content_view, :lifecycle_environment => @system.environment)
      @organization = get_organization
    end

    describe "register with activation key should fail"  do
      it "without specifying owner (organization)" do
        post('consumer_activate', :activation_keys => 'non_existent_key')
        assert_response 404
      end

      it "with unknown organization" do
        post('consumer_activate', :owner => 'not_an_organization', :activation_keys => 'non_existent_key')
        assert_response 404
      end

      it "with known organization and no activation_keys" do
        post('consumer_activate', :owner => @organization.label, :activation_keys => '')
        assert_response 400
      end
    end

    describe "register with activation key" do
      before do
        @facts = { 'network.hostname' => 'somehostname'}
        @activation_key = katello_activation_keys(:simple_key)
      end

      it "should register" do
        system = katello_systems(:simple_server)
        host = @host
        Resources::Candlepin::Consumer.stubs(:get)

        System.expects(:new).returns(system)
        ::Katello::Host::SubscriptionAspect.expects(:new_host_from_rhsm_params).returns(host)
        assert_sync_task(::Actions::Katello::Host::Register, host, system, {'facts' => @facts}, nil, [@activation_key])

        post(:consumer_activate, :organization_id => @activation_key.organization.label,
             :activation_keys => @activation_key.name, :facts => @facts)

        assert_response :success
      end
    end

    describe "register with a lifecycle environment" do
      before do
        @facts = { 'network.hostname' => 'somehostname'}
        @content_view_environment = ContentViewEnvironment.find(katello_content_view_environments(:library_default_view_environment))
      end

      it "should register" do
        system = katello_systems(:simple_server)
        host = @host
        Resources::Candlepin::Consumer.stubs(:get)

        System.expects(:new).returns(system)
        ::Katello::Host::SubscriptionAspect.expects(:new_host_from_rhsm_params).returns(host)
        assert_sync_task(::Actions::Katello::Host::Register, host, system, {'facts' => @facts}, @content_view_environment)

        post(:consumer_create, :organization_id => @content_view_environment.content_view.organization.label,
             :environment_id => @content_view_environment.cp_id, :facts => @facts)

        assert_response :success
      end
    end

    describe "update enabled_repos", :katello => true do
      before do
        User.stubs(:consumer?).returns(true)
        System.stubs(:where).returns(@system)
        System.any_instance.stubs(:first).returns(@system)
        uuid = @host.subscription_aspect.uuid
        ::Host.any_instance.stubs(:content_host).returns(@system)
        User.stubs(:current).returns(CpConsumerUser.new(:uuid => uuid, :login => uuid))
        Repository.stubs(:where).with(:relative_path => 'foo').returns([OpenStruct.new(:pulp_id => 'a')])
        Repository.stubs(:where).with(:relative_path => 'bar').returns([OpenStruct.new(:pulp_id => 'b')])
      end
      let(:enabled_repos) do
        {
          "repos" => [
            {
              "baseurl" => ["https://hostname/pulp/repos/foo"]
            },
            {
              "baseurl" => ["https://hostname/pulp/repos/bar"]
            }
          ]
        }
      end

      it "should bind all" do
        Host::ContentAspect.any_instance.expects(:update_repositories_by_paths).with(["/pulp/repos/foo", "/pulp/repos/bar"])
        System.any_instance.expects(:save_bound_repos_by_path!).with(["/pulp/repos/foo", "/pulp/repos/bar"])
        put :enabled_repos, :id => @host.subscription_aspect.uuid, :enabled_repos => enabled_repos
        assert_equal 200, response.status
      end
    end

    describe "list owners" do
      it 'should return organizations admin user is assigned to' do
        User.current = User.find(users(:admin))
        get :list_owners, :login => User.current.login

        assert_empty((JSON.parse(response.body).collect { |org| org['displayName'] } - Organization.pluck(:name)))
      end

      it 'should return organizations user is assigned to' do
        setup_current_user_with_permissions(:my_organizations)

        get :list_owners, :login => User.current.login
        assert_equal JSON.parse(response.body).first['displayName'], taxonomies(:empty_organization).name
      end

      it "should protect list owners with authentication" do
        get :list_owners, :login => User.current.login
        assert_response 200
      end

      it "should prevent listing owners for unauthenticated requests" do
        User.current = nil
        session[:user] = nil
        set_basic_auth('100', '100')
        get :list_owners, :login => 100
        assert_response 401
      end
    end

    it "test_list_owners_protected" do
      assert_protected_action(:list_owners, :my_organizations) do
        get :list_owners, :login => User.current.login
      end
    end

    it "test_rhsm_index_protected" do
      assert_protected_action(:rhsm_index, :view_lifecycle_environments) do
        get :rhsm_index, :organization_id => @organization.label
      end
    end

    it "test_consumer_create_protected" do
      assert_protected_action(:consumer_create, [[:create_content_hosts,
                                                  :view_lifecycle_environments, :view_content_views]]) do
        post :consumer_create, :environment_id => @organization.library.content_view_environments.first.cp_id
      end
    end

    it "test_upload_package_profile_protected" do
      Resources::Candlepin::Consumer.stubs(:get)
      assert_protected_action(:upload_package_profile, :edit_content_hosts) do
        put :upload_package_profile, :id => @host.subscription_aspect.uuid
      end
    end

    it "test_regenerate_identity_certificates_protected" do
      Resources::Candlepin::Consumer.stubs(:get)
      assert_protected_action(:regenerate_identity_certificates, :edit_content_hosts) do
        post :regenerate_identity_certificates, :id => @host.subscription_aspect.uuid
      end
    end

    describe "hypervisors_update" do
      it "hypervisors_update_correct_env_cv" do
        @controller.stubs(:authorize_client_or_admin)
        System.stubs(:first).returns(@system)
        uuid = @system.uuid
        User.stubs(:consumer?).returns(true)
        User.stubs(:current).returns(CpConsumerUser.new(:uuid => uuid, :login => uuid))
        System.stubs(:register_hypervisors).returns({})
        System.expects(:register_hypervisors).with(@system.environment, @system.content_view,
            "owner" => "Empty_Organization", "env" => "library_default_view_library")
        post :hypervisors_update
        assert_response 200
      end

      it "hypervisors_update_ignore_params" do
        @controller.stubs(:authorize_client_or_admin)
        System.stubs(:first).returns(@system)
        uuid = @system.uuid
        User.stubs(:consumer?).returns(true)
        User.stubs(:current).returns(CpConsumerUser.new(:uuid => uuid, :login => uuid))
        System.stubs(:register_hypervisors).returns({})
        System.expects(:register_hypervisors).with(@system.environment, @system.content_view,
            "owner" => "Empty_Organization", "env" => "library_default_view_library")
        post(:hypervisors_update, :owner => 'owner', :env => 'dev/dev')
        assert_response 200
      end
    end

    describe "available releases" do
      it "can be listed by matching consumer" do
        # Stub out the current user to simulate consumer auth.
        uuid = @host.subscription_aspect.uuid
        User.stubs(:consumer?).returns(true)
        User.stubs(:current).returns(CpConsumerUser.new(:uuid => uuid, :login => uuid))

        get :available_releases, :id => @host.subscription_aspect.uuid
        assert_response 200
      end

      it "forbidden with invalid consumer" do
        # Stub out the current user to simulate consumer auth.
        uuid = 4444
        User.stubs(:consumer?).returns(true)
        User.stubs(:current).returns(CpConsumerUser.new(:uuid => uuid, :login => uuid))
        # Getting the available releases for a different consumer
        # should not be allowed.
        get :available_releases, :id => @host.subscription_aspect.uuid
        assert_response 403
      end
    end

    describe "consumer show" do
      before do
        Resources::Candlepin::Consumer.stubs(:get).returns(Resources::Candlepin::Consumer.new(:id => 1, :uuid => 2))
      end

      it "can be accessed by user" do
        User.current = setup_user_with_permissions(:create_content_hosts, User.find(users(:restricted).id))
        get :consumer_show, :id => @host.subscription_aspect.uuid
        assert_response 200
      end

      it "can be accessed by client" do
        uuid = @host.subscription_aspect.uuid
        User.stubs(:current).returns(CpConsumerUser.new(:uuid => uuid, :login => uuid))
        get :consumer_show, :id => uuid
        assert_response 200
      end
    end
  end
end
