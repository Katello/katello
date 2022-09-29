# encoding: utf-8

require "katello_test_helper"

#rubocop:disable Metrics/ModuleLength
module Katello
  #rubocop:disable Metrics/BlockLength
  describe Api::Rhsm::CandlepinProxiesController do
    include Katello::AuthorizationSupportMethods
    include Support::ForemanTasks::Task

    before do
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))

      @content_facet_one = katello_content_facets(:content_facet_one)

      @organization = get_organization
      @host = FactoryBot.create(
        :host,
        :with_content,
        :with_subscription,
        :content_facet => @content_facet_one,
        :organization => @content_facet_one.single_content_view.organization
      )
      location = taxonomies(:location1)
      Setting[:default_location_subscribed_hosts] = location.title
    end

    describe "register with activation key should fail" do
      it "without specifying owner (organization)" do
        post('consumer_activate', params: { :activation_keys => 'non_existent_key' })
        assert_response 404
      end

      it "with unknown organization" do
        post('consumer_activate', params: { :owner => 'not_an_organization', :activation_keys => 'non_existent_key' })
        assert_response 404
      end

      it "with known organization and no activation_keys" do
        post('consumer_activate', params: { :owner => @organization.label, :activation_keys => '' })
        assert_response 400
      end
    end

    describe "register with activation key" do
      before do
        @facts = { 'network.hostname' => 'somehostname'}
        @activation_key = katello_activation_keys(:simple_key)
      end

      it "should register" do
        Resources::Candlepin::Consumer.stubs(:get)

        ::Katello::RegistrationManager.expects(:process_registration).with({'facts' => @facts}, nil, [@activation_key]).returns(@host)

        post(:consumer_activate, params: { :organization_id => @activation_key.organization.label, :activation_keys => @activation_key.name, :facts => @facts })

        assert_response :success
      end

      it "de-duplicates provided activation key names" do
        Resources::Candlepin::Consumer.stubs(:get)

        ::Katello::RegistrationManager.expects(:process_registration).with({'facts' => @facts}, nil, [@activation_key]).returns(@host)

        key_names = "#{@activation_key.name},#{@activation_key.name}"

        post(:consumer_activate, params: { :organization_id => @activation_key.organization.label,
                                           :activation_keys => key_names, :facts => @facts })

        assert_response :success
      end

      it "should not register with dead services" do
        ::Katello::RegistrationManager.expects(:check_registration_services).returns(false)
        ::Katello::RegistrationManager.expects(:process_registration).never

        post(:consumer_activate, params: { :organization_id => @activation_key.organization.label,
                                           :activation_keys => @activation_key.name, :facts => @facts })

        assert_response 500
      end
    end

    describe "register with a lifecycle environment" do
      before do
        @facts = { 'network.hostname' => 'somehostname'}
        @content_view_environment = ContentViewEnvironment.find(katello_content_view_environments(:library_default_view_environment).id)
      end

      it "should register" do
        Resources::Candlepin::Consumer.stubs(:get)
        ::Katello::RegistrationManager.expects(:check_registration_services).returns(true)
        ::Katello::RegistrationManager.expects(:process_registration).with({'facts' => @facts }, [@content_view_environment]).returns(@host)

        post(:consumer_create, params: { :organization_id => @content_view_environment.content_view.organization.label, :environment_id => @content_view_environment.cp_id, :facts => @facts })

        assert_response :success
      end

      it "should register with new environments param" do
        Resources::Candlepin::Consumer.stubs(:get)
        ::Katello::RegistrationManager.expects(:check_registration_services).returns(true)
        ::Katello::RegistrationManager.expects(:process_registration).with({'facts' => @facts }, [@content_view_environment]).returns(@host)

        post(:consumer_create, params: { :organization_id => @content_view_environment.content_view.organization.label, :environments => [{id: @content_view_environment.cp_id}], :facts => @facts })

        assert_response :success
      end

      it "should not register with multiple envs" do
        ::Katello::RegistrationManager.expects(:process_registration).never

        post(:consumer_create, params: { :organization_id => @content_view_environment.content_view.organization.label, :environments => [{id: @content_view_environment.cp_id}, {id: @content_view_environment.cp_id}], :facts => @facts })

        body = JSON.parse(response.body)

        assert_equal 'Registering to multiple environments is not enabled.', body['displayMessage']
        assert_response 400
      end

      it "should not register" do
        ::Katello::RegistrationManager.expects(:check_registration_services).returns(false)
        ::Katello::RegistrationManager.expects(:process_registration).never

        post(:consumer_create, params: { :organization_id => @content_view_environment.content_view.organization.label,
                                         :environment_id => @content_view_environment.cp_id, :facts => @facts })

        assert_response 500
      end
    end

    describe "update enabled_repos" do
      before do
        User.stubs(:consumer?).returns(true)
        uuid = @host.subscription_facet.uuid
        stub_cp_consumer_with_uuid(uuid)
      end
      let(:enabled_repos) do
        {
          "repos" => [
            {
              "baseurl" => ["https://hostname/pulp/content/foo"]
            },
            {
              "baseurl" => ["https://hostname/pulp/content/bar"]
            },
            {
              "baseurl" => ["https://hostname/pulp/content/bar"]
            },
            {
              "baseurl" => ["https://hostname/pulp/content/baz"]
            }
          ]
        }
      end

      it "should bind all" do
        Host::ContentFacet.any_instance.expects(:update_repositories_by_paths).with(
          [
            "/pulp/content/foo",
            "/pulp/content/bar",
            "/pulp/content/bar",
            "/pulp/content/baz"
          ])
        put :enabled_repos, params: { :id => @host.subscription_facet.uuid, :enabled_repos => enabled_repos }
        assert_equal 200, response.status
      end

      it "should fail with missing attribute 1" do
        put :enabled_repos, params: { :id => @host.subscription_facet.uuid }
        assert_equal 400, response.status
      end

      it "should fail with missing attribute 2" do
        put :enabled_repos, params: { :id => @host.subscription_facet.uuid, :enabled_repos => {} }
        assert_equal 400, response.status
      end

      it "should unbind all" do
        Host::ContentFacet.any_instance.expects(:update_repositories_by_paths).with([])
        put :enabled_repos, params: { :id => @host.subscription_facet.uuid, :enabled_repos => {"repos" => []}}
        assert_equal 200, response.status
      end

      it "should update facts" do
        facts = {'rhsm_fact' => 'rhsm_value'}
        ::Host.any_instance.expects(:update_candlepin_associations).with("facts" => facts)
        put :facts, params: { :id => @host.subscription_facet.uuid, :facts => facts }
        assert_equal 200, response.status
      end
    end

    describe "update facts with non-consumer user" do
      it "should prevent update facts for unauthorized user" do
        login_user(setup_user_with_permissions(:view_hosts, User.find(users(:restricted).id)))
        facts = {'rhsm_fact' => 'rhsm_value'}
        put :facts, params: { :id => @host.subscription_facet.uuid, :facts => facts }
        assert_response 403
      end

      it "should allow update facts for admin" do
        login_user(User.find(users(:admin).id))
        uuid = @host.subscription_facet.uuid
        stub_cp_consumer_with_uuid(uuid)
        facts = {'rhsm_fact' => 'rhsm_value'}
        ::Host.any_instance.expects(:update_candlepin_associations).with("facts" => facts)
        put :facts, params: { :id => @host.subscription_facet.uuid, :facts => facts}
        assert_response 200
      end
    end

    describe "list owners" do
      it 'should return organizations admin user is assigned to' do
        User.current = User.find(users(:admin).id)
        get :list_owners, params: { :login => User.current.login }

        assert_empty((JSON.parse(response.body).collect { |org| org['displayName'] } - Organization.pluck(:name)))
      end

      it 'should return organizations user is assigned to' do
        setup_current_user_with_permissions(:my_organizations)

        get :list_owners, params: { :login => User.current.login }
        assert_equal JSON.parse(response.body).first['displayName'], taxonomies(:empty_organization).name
      end

      it "should protect list owners with authentication" do
        get :list_owners, params: { :login => User.current.login }
        assert_response 200
      end

      it "should prevent listing owners for unauthenticated requests" do
        User.current = nil
        session[:user] = nil
        set_basic_auth('100', '100')
        get :list_owners, params: { :login => 100 }
        assert_response 401
      end
    end

    it "test_list_owners_protected" do
      assert_protected_action(:list_owners, :my_organizations) do
        get :list_owners, params: { :login => User.current.login }
      end
    end

    it "test_rhsm_index_protected" do
      assert_protected_action(:rhsm_index, :view_lifecycle_environments, [], [@organization]) do
        get :rhsm_index, params: { :organization_id => @organization.label }
      end
    end

    it "test_consumer_create_protected" do
      assert_protected_action(:consumer_create, [[:create_hosts,
                                                  :view_lifecycle_environments, :view_content_views]]) do
        post :consumer_create, params: { :environment_id => @organization.library.content_view_environments.first.cp_id }
      end
    end

    it "test_upload_tracer_profile_protected" do
      Resources::Candlepin::Consumer.stubs(:get)
      assert_protected_action(:upload_tracer_profile, :edit_hosts) do
        put :upload_tracer_profile, params: { :id => @host.subscription_facet.uuid }
      end
    end

    def test_regenerate_indentity_certificates
      consumer_stub = stub(:regenerate_identity_certificates => true)

      Candlepin::Consumer.expects(:new).with(@host.subscription_facet.uuid, @host.organization.label).returns(consumer_stub)
      Resources::Candlepin::Consumer.expects(:get).with(@host.subscription_facet.uuid)

      post :regenerate_identity_certificates, params: { :id => @host.subscription_facet.uuid }
    end

    it "test_regenerate_identity_certificates_protected" do
      Resources::Candlepin::Consumer.stubs(:get)
      assert_protected_action(:regenerate_identity_certificates, :edit_hosts) do
        post :regenerate_identity_certificates, params: { :id => @host.subscription_facet.uuid }
      end
    end

    describe "hypervisors_update" do
      it "hypervisors_update_with_no_owner" do
        post :hypervisors_update
        assert_response 403
      end

      it "hypervisors_update" do
        assert_sync_task(::Actions::Katello::Host::Hypervisors) do |params|
          assert_equal params, 'owner' => @organization.label, 'env' => nil
        end

        post(:hypervisors_update, :params => {:owner => @organization.label, :env => 'dev/dev'})
        assert_response 200
      end
    end

    describe "async_hypervisors_update" do
      it "hypervisors_update" do
        owner = @organization.label
        reporter_id = 100
        env = 'dev/dev'
        Katello::Resources::Candlepin::Consumer.expects(:async_hypervisors).returns('id' => 'foo').with do |params|
          assert_equal params[:owner], owner
          assert_equal params[:reporter_id], reporter_id
        end

        assert_async_task(::Actions::Katello::Host::Hypervisors) do |params, options|
          assert_nil params
          assert_equal options, :task_id => 'foo'
        end

        post(:async_hypervisors_update, :params => {owner: owner, reporter_id: reporter_id, env: env})
        assert_response 200
      end
    end

    describe "hypervisors_update_with_consumer_auth" do
      before do
        @controller.stubs(:client_authorized?).returns(true)
        @controller.stubs(:find_host).returns(@host)
        uuid = @host.subscription_facet.uuid
        User.stubs(:consumer?).returns(true)
        stub_cp_consumer_with_uuid(uuid)
      end

      it "hypervisors_update_correct_env_cv" do
        assert_sync_task(::Actions::Katello::Host::Hypervisors) do |params|
          assert_equal params, 'owner' => @host.organization.label, 'env' => nil
        end
        post :hypervisors_update
        assert_response 200
      end

      it "hypervisors_update_ignore_params" do
        assert_sync_task(::Actions::Katello::Host::Hypervisors) do |params|
          assert_equal params, 'owner' => @host.organization.label, 'env' => nil
        end
        post(:hypervisors_update, :params => {:owner => 'owner', :env => 'dev/dev'})
        assert_response 200
      end
    end

    describe "hypervisors_heartbeat" do
      it "sends the request to candlepin" do
        Katello::Resources::Candlepin::Consumer.expects(:hypervisors_heartbeat).with(owner: @organization.label, reporter_id: 123)

        put :hypervisors_heartbeat, params: { owner: @organization.label, reporter_id: 123 }

        assert_response 200
      end
    end

    describe "available releases" do
      it "can be listed by matching consumer" do
        # Stub out the current user to simulate consumer auth.
        uuid = @host.subscription_facet.uuid
        User.stubs(:consumer?).returns(true)
        stub_cp_consumer_with_uuid(uuid)
        get :available_releases, params: { :id => @host.subscription_facet.uuid }
        assert_response 200
      end

      it "forbidden with invalid consumer" do
        # Stub out the current user to simulate consumer auth.
        uuid = 4444
        User.stubs(:consumer?).returns(true)
        stub_cp_consumer_with_uuid(uuid)
        # Getting the available releases for a different consumer
        # should not be allowed.
        get :available_releases, params: { :id => @host.subscription_facet.uuid }
        assert_response 403
      end
    end

    describe "consumer destroy" do
      before do
        uuid = @host.subscription_facet.uuid
        User.stubs(:consumer?).returns(true)
        stub_cp_consumer_with_uuid(uuid)
      end
      it "should unregister" do
        Setting[:unregister_delete_host] = false

        ::Katello::RegistrationManager.expects(:unregister_host).with(@host, :unregistering => true)
        delete :consumer_destroy, params: { :id => @host.subscription_facet.uuid }

        assert_response 204
      end

      it "should destroy the host if setting is set" do
        Setting[:unregister_delete_host] = true

        ::Katello::RegistrationManager.expects(:unregister_host).with(@host, :unregistering => false)
        delete :consumer_destroy, params: { :id => @host.subscription_facet.uuid }

        assert_response 204
      end

      it "should error if backend services are down" do
        ::Katello::RegistrationManager.expects(:check_registration_services).returns(false)

        ::Katello::RegistrationManager.expects(:unregister_host).never
        delete :consumer_destroy, params: { :id => @host.subscription_facet.uuid }

        assert_response 500
      end
    end

    describe "consumer show" do
      before do
        Resources::Candlepin::Consumer.stubs(:get).returns(Resources::Candlepin::Consumer.new(:id => 1, :uuid => 2))
      end

      it "can be accessed by user" do
        User.current = setup_user_with_permissions(:create_hosts, User.find(users(:restricted).id))
        get :consumer_show, params: { :id => @host.subscription_facet.uuid }
        assert_response 200
      end

      it "can be accessed by client" do
        uuid = @host.subscription_facet.uuid
        stub_cp_consumer_with_uuid(uuid)
        get :consumer_show, params: { :id => uuid }
        assert_response 200
      end
    end

    describe "consumer serials" do
      before do
        Resources::Candlepin::Consumer.stubs(:serials).returns([{'serial' => 'asdf'}])
      end

      it "can fetch serials" do
        uuid = @host.subscription_facet.uuid
        assert_nil @host.subscription_facet.last_checkin
        stub_cp_consumer_with_uuid(uuid)

        get :serials, params: { :id => uuid }
        assert_response 200
        refute_nil @host.subscription_facet.reload.last_checkin
      end
    end

    describe "get parent host" do
      it "can get parent host" do
        capsule = "foocapsule.example.com"
        Setting[:foreman_url] = 'https://foreman.example.com'

        host_and_capsule = {"HTTP_X_FORWARDED_HOST" => "#{capsule}:8443, foo.example.com"}
        just_capsule = {"HTTP_X_FORWARDED_HOST" => "#{capsule}:8443"}
        nil_host = {}

        assert_equal @controller.get_parent_host(host_and_capsule), "#{capsule}"
        assert_equal @controller.get_parent_host(just_capsule), "#{capsule}"
        assert_equal 'foreman.example.com', @controller.get_parent_host(nil_host)
      end
    end
  end
end
