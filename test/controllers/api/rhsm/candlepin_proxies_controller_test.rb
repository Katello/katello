# encoding: utf-8

require "katello_test_helper"

module Katello
  describe Api::Rhsm::CandlepinProxiesController do
    include Katello::AuthorizationSupportMethods
    include Support::ForemanTasks::Task

    before do
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))

      @content_view = katello_content_views(:acme_default)
      @environment = katello_environments(:library)

      @organization = get_organization
      @host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                 :lifecycle_environment => @environment, :organization => @content_view.organization)
    end

    describe "register with activation key should fail" do
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
        Resources::Candlepin::Consumer.stubs(:get)

        ::Katello::Host::SubscriptionFacet.expects(:new_host_from_facts).returns(@host)
        assert_sync_task(::Actions::Katello::Host::Register, @host, {'facts' => @facts}, nil, [@activation_key])

        post(:consumer_activate, :organization_id => @activation_key.organization.label,
             :activation_keys => @activation_key.name, :facts => @facts)

        assert_response :success
      end
    end

    describe "register with a lifecycle environment" do
      before do
        @facts = { 'network.hostname' => 'somehostname'}
        @content_view_environment = ContentViewEnvironment.find(katello_content_view_environments(:library_default_view_environment).id)
      end

      it "should register" do
        Resources::Candlepin::Consumer.stubs(:get)

        ::Katello::Host::SubscriptionFacet.expects(:new_host_from_facts).returns(@host)
        assert_sync_task(::Actions::Katello::Host::Register, @host, {'facts' => @facts }, @content_view_environment)

        post(:consumer_create, :organization_id => @content_view_environment.content_view.organization.label,
             :environment_id => @content_view_environment.cp_id, :facts => @facts)

        assert_response :success
      end
    end

    describe "update enabled_repos" do
      before do
        User.stubs(:consumer?).returns(true)
        uuid = @host.subscription_facet.uuid
        stub_cp_consumer_with_uuid(uuid)
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
        Host::ContentFacet.any_instance.expects(:update_repositories_by_paths).with(["/pulp/repos/foo", "/pulp/repos/bar"])
        put :enabled_repos, :id => @host.subscription_facet.uuid, :enabled_repos => enabled_repos
        assert_equal 200, response.status
      end

      it "should update facts" do
        facts = {'rhsm_fact' => 'rhsm_value'}
        assert_async_task(::Actions::Katello::Host::Update)

        put :facts, :id => @host.subscription_facet.uuid, :facts => facts
        assert_equal 200, response.status
      end
    end

    describe "update facts with non-consumer user" do
      it "should prevent update facts for unauthorized user" do
        login_user(setup_user_with_permissions(:view_hosts, User.find(users(:restricted).id)))
        facts = {'rhsm_fact' => 'rhsm_value'}
        put :facts, :id => @host.subscription_facet.uuid, :facts => facts
        assert_response 403
      end

      it "should allow update facts for admin" do
        login_user(User.find(users(:admin).id))
        uuid = @host.subscription_facet.uuid
        stub_cp_consumer_with_uuid(uuid)
        facts = {'rhsm_fact' => 'rhsm_value'}
        assert_async_task(::Actions::Katello::Host::Update)
        put :facts, :id => @host.subscription_facet.uuid, :facts => facts
        assert_response 200
      end
    end

    describe "list owners" do
      it 'should return organizations admin user is assigned to' do
        User.current = User.find(users(:admin).id)
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
      assert_protected_action(:rhsm_index, :view_lifecycle_environments, [], [@organization]) do
        get :rhsm_index, :organization_id => @organization.label
      end
    end

    it "test_consumer_create_protected" do
      assert_protected_action(:consumer_create, [[:create_hosts,
                                                  :view_lifecycle_environments, :view_content_views]]) do
        post :consumer_create, :environment_id => @organization.library.content_view_environments.first.cp_id
      end
    end

    it "test_upload_tracer_profile_protected" do
      Resources::Candlepin::Consumer.stubs(:get)
      assert_protected_action(:upload_tracer_profile, :edit_hosts) do
        put :upload_tracer_profile, :id => @host.subscription_facet.uuid
      end
    end

    def test_regenerate_indentity_certificates
      consumer_stub = stub(:regenerate_identity_certificates => true)

      Candlepin::Consumer.expects(:new).with(@host.subscription_facet.uuid, @host.organization.label).returns(consumer_stub)
      Resources::Candlepin::Consumer.expects(:get).with(@host.subscription_facet.uuid)

      post :regenerate_identity_certificates, :id => @host.subscription_facet.uuid
    end

    it "test_regenerate_identity_certificates_protected" do
      Resources::Candlepin::Consumer.stubs(:get)
      assert_protected_action(:regenerate_identity_certificates, :edit_hosts) do
        post :regenerate_identity_certificates, :id => @host.subscription_facet.uuid
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

        post(:hypervisors_update, :owner => @organization.label, :env => 'dev/dev')
        assert_response 200
      end
    end

    describe "async_hypervisors_update" do
      it "hypervisors_update" do
        Katello::Resources::Candlepin::Consumer.expects(:async_hypervisors).returns('id' => 'foo')

        assert_async_task(::Actions::Katello::Host::Hypervisors) do |params, options|
          assert_nil params
          assert_equal options, :task_id => 'foo'
        end

        post(:async_hypervisors_update, :owner => @organization.label, :env => 'dev/dev')
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
        post(:hypervisors_update, :owner => 'owner', :env => 'dev/dev')
        assert_response 200
      end
    end

    describe "available releases" do
      it "can be listed by matching consumer" do
        # Stub out the current user to simulate consumer auth.
        uuid = @host.subscription_facet.uuid
        User.stubs(:consumer?).returns(true)
        stub_cp_consumer_with_uuid(uuid)
        get :available_releases, :id => @host.subscription_facet.uuid
        assert_response 200
      end

      it "forbidden with invalid consumer" do
        # Stub out the current user to simulate consumer auth.
        uuid = 4444
        User.stubs(:consumer?).returns(true)
        stub_cp_consumer_with_uuid(uuid)
        # Getting the available releases for a different consumer
        # should not be allowed.
        get :available_releases, :id => @host.subscription_facet.uuid
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

        assert_sync_task(::Actions::Katello::Host::Unregister, @host)
        delete :consumer_destroy, :id => @host.subscription_facet.uuid

        assert_response 204
      end

      it "should destroy the host if setting is set" do
        Setting[:unregister_delete_host] = true

        assert_sync_task(::Actions::Katello::Host::Destroy, @host)
        delete :consumer_destroy, :id => @host.subscription_facet.uuid

        assert_response 204
      end
    end

    describe "consumer show" do
      before do
        Resources::Candlepin::Consumer.stubs(:get).returns(Resources::Candlepin::Consumer.new(:id => 1, :uuid => 2))
      end

      it "can be accessed by user" do
        User.current = setup_user_with_permissions(:create_hosts, User.find(users(:restricted).id))
        get :consumer_show, :id => @host.subscription_facet.uuid
        assert_response 200
      end

      it "can be accessed by client" do
        uuid = @host.subscription_facet.uuid
        stub_cp_consumer_with_uuid(uuid)
        get :consumer_show, :id => uuid
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

        get :serials, :id => uuid
        assert_response 200
        refute_nil @host.subscription_facet.reload.last_checkin
      end
    end

    describe "get parent host" do
      it "can get parent host" do
        capsule = "foocapsule.example.com"

        host_and_capsule = {"HTTP_X_FORWARDED_SERVER" => "#{capsule}, foo.example.com"}
        just_capsule = {"HTTP_X_FORWARDED_SERVER" => "#{capsule}"}
        nil_host = {}

        assert_equal @controller.get_parent_host(host_and_capsule), "#{capsule}"
        assert_equal @controller.get_parent_host(just_capsule), "#{capsule}"
        assert_includes [Facter.value(:fqdn), SETTINGS[:fqdn]], @controller.get_parent_host(nil_host)
      end
    end
  end
end
