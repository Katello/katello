# encoding: utf-8

require "katello_test_helper"

module Katello
  # rubocop:disable Metrics/ClassLength
  class Api::V2::HostsBulkActionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def permissions
      @view_permission = :view_hosts
      @update_permission = :edit_hosts
      @destroy_permission = :destroy_hosts
    end

    def models
      @view = katello_content_views(:library_view)

      @view_2 = katello_content_views(:acme_default)
      @library = katello_environments(:library)

      @host1 = FactoryBot.create(:host, :with_subscription, :with_content, :organization => @view.organization, :content_view => @view, :lifecycle_environment => @library)
      @host2 = FactoryBot.create(:host, :with_subscription, :with_content, :organization => @view.organization, :content_view => @view, :lifecycle_environment => @library)
      @host_ids = [@host1.id, @host2.id]
      @host_names = [@host1.name, @host2.name]

      @org = @view.organization
      @host_collection1 = katello_host_collections(:simple_host_collection)
      @host_collection1.hosts << @host1
      @host_collection2 = katello_host_collections(:another_simple_host_collection)
    end

    let(:host_one_trace) do
      Katello::HostTracer.create!(host: @host1, application: 'kernel', app_type: 'static', helper: 'reboot the system')
    end

    let(:host_two_trace) do
      Katello::HostTracer.create!(host: @host2, application: 'dbus', app_type: 'static', helper: 'reboot the system')
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      @request.env['HTTP_ACCEPT'] = 'application/json'

      setup_foreman_routes
      permissions
      models
    end

    def test_add_host_collection
      assert_equal 1, @host1.host_collections.count # system initially has simple_host_collection
      put :bulk_add_host_collections, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :host_collection_ids => [@host_collection1.id, @host_collection2.id] }

      assert_response :success
      assert_equal 2, @host1.host_collections.count
    end

    def test_remove_host_collection
      assert_equal 1, @host1.host_collections.count # system initially has simple_host_collection
      put :bulk_remove_host_collections, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :host_collection_ids => [@host_collection1.id, @host_collection2.id] }

      assert_response :success
      assert_equal 0, @host1.host_collections.count
    end

    def test_install_package
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task(::Actions::Katello::BulkAgentAction) do |action_class, hosts, options|
        assert_equal action_class, ::Actions::Katello::Host::Package::Install
        assert_equal ['foo'], options[:content]
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end

      put :install_content, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_type => 'package', :content => ['foo'] }

      assert_response :success
    end

    def test_update_package
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task(::Actions::Katello::BulkAgentAction) do |action_class, hosts, options|
        assert_equal action_class, ::Actions::Katello::Host::Package::Update
        assert_equal ['foo'], options[:content]
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end

      put :update_content, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_type => 'package', :content => ['foo'] }

      assert_response :success
    end

    def test_remove_package
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task(::Actions::Katello::BulkAgentAction) do |action_class, hosts, options|
        assert_equal action_class, ::Actions::Katello::Host::Package::Remove
        assert_equal ['foo'], options[:content]
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end

      put :remove_content, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_type => 'package', :content => ['foo'] }

      assert_response :success
    end

    def test_install_package_group
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task(::Actions::Katello::BulkAgentAction) do |action_class, hosts, options|
        assert_equal action_class, ::Actions::Katello::Host::PackageGroup::Install
        assert_equal ['foo group'], options[:content]
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end

      put :install_content, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_type => 'package_group', :content => ['foo group'] }

      assert_response :success
    end

    def test_update_package_group
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task(::Actions::Katello::BulkAgentAction) do |action_class, hosts, options|
        assert_equal action_class, ::Actions::Katello::Host::PackageGroup::Install
        assert_equal ['foo group'], options[:content]
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end

      put :update_content, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_type => 'package_group', :content => ['foo group'] }

      assert_response :success
    end

    def test_remove_package_group
      ::Katello.stubs(:with_katello_agent?).returns(true)

      assert_async_task(::Actions::Katello::BulkAgentAction) do |action_class, hosts, options|
        assert_equal action_class, ::Actions::Katello::Host::PackageGroup::Remove
        assert_equal ['foo group'], options[:content]
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end

      put :remove_content, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_type => 'package_group', :content => ['foo group'] }

      assert_response :success
    end

    def test_install_errata
      errata = katello_errata("bugfix")
      @host1.content_facet.applicable_errata << errata
      ::Katello.stubs(:with_katello_agent?).returns(true)
      @controller.expects(:async_task).with(::Actions::BulkAction, ::Actions::Katello::Host::Erratum::ApplicableErrataInstall,
                                            [@host1], :errata_ids => [errata.errata_id]).returns({})

      put :install_content, params: { :included => {:ids => [@host1.id]}, :organization_id => @org.id, :content_type => 'errata', :content => [errata.errata_id] }

      assert_response :success
    end

    def test_destroy_hosts
      assert_async_task(::Actions::BulkAction) do |action_class, hosts|
        assert_equal action_class, ::Actions::Katello::Host::Destroy
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end

      put :destroy_hosts, params: { :included => {:ids => @host_ids}, :organization_id => @org.id }
      assert_response :success
    end

    def test_content_view_environment
      assert_async_task(::Actions::BulkAction) do |action_class, hosts, view_id, library_id|
        assert_equal action_class, ::Actions::Katello::Host::UpdateContentView
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal @view_2.id, view_id
        assert_equal @library.id, library_id
      end

      put :environment_content_view, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :environment_id => @library.id, :content_view_id => @view_2.id }

      assert_response :success
    end

    def test_system_purpose
      host_service_level = 'Standard'
      host_purpose_role = 'Red Hat Enterprise Linux Server'
      host_purpose_usage = 'Production'
      host_purpose_addons = ['foo']

      assert_async_task(::Actions::BulkAction) do |action_class, hosts, service_level_param, purpose_role_param, purpose_usage_param, purpose_addons_param|
        assert_equal action_class, ::Actions::Katello::Host::UpdateSystemPurpose
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal host_service_level, service_level_param
        assert_equal host_purpose_role, purpose_role_param
        assert_equal host_purpose_usage, purpose_usage_param
        assert_equal host_purpose_addons, purpose_addons_param
      end

      put :system_purpose, params: { :included => {:ids => @host_ids}, :service_level => host_service_level, :purpose_role => host_purpose_role,
                                     :purpose_usage => host_purpose_usage, :purpose_addons => host_purpose_addons}

      assert_response :success
    end

    def test_system_purpose_permission
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host

      host_service_level = 'Standard'
      host_purpose_usage = 'Production'
      host_purpose_role = 'Red Hat Enterprise Linux Server'
      host_purpose_addons = ['foo']

      assert_protected_action(:release_version, good_perms, bad_perms) do
        put :system_purpose, params: { :included => {:ids => @host_ids}, :service_level => host_service_level, :purpose_role => host_purpose_role,
                                       :purpose_usage => host_purpose_usage, :purpose_addons => host_purpose_addons}
      end
    end

    def test_release_version
      release_version = "7.2"
      assert_async_task(::Actions::BulkAction) do |action_class, hosts, release_version_param|
        assert_equal action_class, ::Actions::Katello::Host::UpdateReleaseVersion
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal release_version, release_version_param
      end

      put :release_version, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :release_version => release_version }

      assert_response :success
    end

    def test_release_version_permission
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host

      assert_protected_action(:release_version, good_perms, bad_perms) do
        put :release_version, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :release_version => "7.2" }
      end
    end

    def allow_restricted_user_to_see_host
      users(:restricted).update_attribute(:organizations, [@org])
      users(:restricted).update_attribute(:locations, [@host1.location, @host2.location].uniq)
    end

    def test_bulk_add_host_collections_permissions
      good_perms = [[@update_permission, :edit_host_collections]]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host

      assert_protected_action(:bulk_add_host_collections, good_perms, bad_perms) do
        put :bulk_add_host_collections, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :host_collection_ids => [@host_collection1.id, @host_collection2.id] }
      end
    end

    def test_bulk_remove_host_collections_permissions
      good_perms = [[@update_permission, :edit_host_collections]]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host
      assert_protected_action(:bulk_remove_host_collections, good_perms, bad_perms) do
        put :bulk_remove_host_collections, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :host_collection_ids => [@host_collection1.id, @host_collection2.id] }
      end
    end

    def test_install_content_permissions
      ::Katello.stubs(:with_katello_agent?).returns(true)

      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host
      assert_protected_action(:install_content, good_perms, bad_perms) do
        put :install_content, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_type => 'package', :content => ['foo'] }
      end
    end

    def test_update_content_permissions
      ::Katello.stubs(:with_katello_agent?).returns(true)

      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host
      assert_protected_action(:update_content, good_perms, bad_perms) do
        put :update_content, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_type => "package", :content => ['foo'] }
      end
    end

    def test_remove_content_permissions
      ::Katello.stubs(:with_katello_agent?).returns(true)

      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host
      assert_protected_action(:remove_content, good_perms, bad_perms) do
        put :remove_content, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_type => 'package', :content => ['foo'] }
      end
    end

    def test_destroy_hosts_permissions
      allow_restricted_user_to_see_host
      good_perms = [@destroy_permission]
      bad_perms = [@view_permission, @update_permission]

      assert_protected_action(:destroy_hosts, good_perms, bad_perms) do
        put :destroy_hosts, params: { :included => {:ids => @host_ids}, :organization_id => @org.id }
      end
    end

    def test_environment_content_view_permission
      good_perms = [[@update_permission, :edit_lifecycle_environments, :edit_content_views]]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host

      assert_protected_action(:environment_content_view, good_perms, bad_perms) do
        put :environment_content_view, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :environment_id => @library.id, :content_view_id => @view.id }
      end
    end

    def test_available_incremental_updates
      ContentViewVersion.any_instance.stubs(:content_counts).returns(
                     :package_count => 0, :errata_count => 0, :puppet_module_count => 0)

      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)

      @host1.content_facet.applicable_errata = @view_repo.errata

      @cv = katello_content_views(:library_dev_view)
      @env = katello_environments(:dev)

      unavailable = @host1.content_facet.applicable_errata -
          @host1.content_facet.installable_errata(@env, @cv)
      @missing_erratum = unavailable.first

      assert @missing_erratum
      post :available_incremental_updates, params: { :included => {:ids => [@host1.id]}, :organization_id => @org.id, :errata_ids => [@missing_erratum.errata_id] }
      assert_response :success
    end

    def test_incremental_updates_no_ids
      post :available_incremental_updates, params: { :included => {:ids => [@host1.id]}, :organization_id => @org.id }
      assert_response :bad_request
    end

    def test_subscription_permissions
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host

      pool = katello_pools(:pool_one)

      assert_protected_action(:content_overrides, good_perms, bad_perms) do
        put :content_overrides, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_overrides => [{:content_label => 'some-content', :value => 1}] }
      end

      assert_protected_action(:add_subscriptions, good_perms, bad_perms) do
        put :add_subscriptions, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :subscriptions => [{:id => pool.id, :quantity => 1}] }
      end

      assert_protected_action(:remove_subscriptions, good_perms, bad_perms) do
        put :remove_subscriptions, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :subscriptions => [{:id => pool.id, :quantity => 1}] }
      end

      assert_protected_action(:auto_attach, good_perms, bad_perms) do
        put :auto_attach, params: { :organization_id => @org.id, :included => {:ids => @host_ids} }
      end
    end

    def test_add_subscriptions
      Organization.any_instance.stubs(:simple_content_access?).returns(false)
      pool = katello_pools(:pool_one)

      assert_async_task(::Actions::BulkAction) do |action_class, hosts, pools_with_quantities|
        assert_equal action_class, ::Actions::Katello::Host::AttachSubscriptions
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal pool, pools_with_quantities[0].pool
        assert_equal [1], pools_with_quantities[0].quantities.map(&:to_i)
      end
      put :add_subscriptions, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :subscriptions => [{:id => pool.id, :quantity => 1}] }
      assert_response :success
    end

    def test_add_subscriptions_with_simple_content_access
      Organization.any_instance.stubs(:simple_content_access?).returns(true)
      pool = katello_pools(:pool_one)
      put :add_subscriptions, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :subscriptions => [{:id => pool.id, :quantity => 1}] }
      assert_response :bad_request
    end

    def test_remove_subscriptions
      pool = katello_pools(:pool_one)

      assert_async_task(::Actions::BulkAction) do |action_class, hosts, pools_with_quantities|
        assert_equal action_class, ::Actions::Katello::Host::RemoveSubscriptions
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal pool, pools_with_quantities[0].pool
        assert_equal [1], pools_with_quantities[0].quantities.map(&:to_i)
      end
      put :remove_subscriptions, params: { :organization_id => @org.id, :included => {:ids => @host_ids}, :subscriptions => [{:id => pool.id, :quantity => 1}] }
      assert_response :success
    end

    def test_auto_attach
      assert_async_task(::Actions::BulkAction) do |action_class, hosts|
        assert_equal action_class, ::Actions::Katello::Host::AutoAttachSubscriptions
        assert_includes hosts, @host1
        assert_includes hosts, @host2
      end
      put :auto_attach, params: { :organization_id => @org.id, :included => {:ids => @host_ids} }
      assert_response :success
    end

    def test_content_overrides
      expected_content_overrides = [{:content_label => 'some-content', :value => 1},
                                    {:content_label => 'some-content2', :value => "default"}]
      expected_content_labels = expected_content_overrides.map { |override| override[:content_label] }
      expected_values = ["1", nil]

      assert_async_task(::Actions::BulkAction) do |action_class, hosts, content_overrides|
        assert_equal action_class, ::Actions::Katello::Host::UpdateContentOverrides
        assert_includes hosts, @host1
        assert_includes hosts, @host2
        assert_equal expected_content_overrides.size, content_overrides.size
        assert_equal expected_content_labels, content_overrides.map(&:content_label)
        assert_equal expected_values, content_overrides.map(&:value)
      end
      put :content_overrides, params: { :included => {:ids => @host_ids}, :organization_id => @org.id, :content_overrides => expected_content_overrides }
      assert_response :success
    end

    def test_module_streams
      post :module_streams, params: {
        included: {:ids => @host_ids},
        organization_id: @org.id,
        host_collection_ids: [@host_collection1.id, @host_collection2.id]
      }

      assert_response :success
    end

    def test_get_host_traces
      host_one_trace
      host_two_trace

      post :traces, params: {
        organization_id: @org.id,
        included: {:ids => @host_ids}
      }

      assert_response :success

      response_body = JSON.parse(response.body)
      assert_equal 2, response_body['total']
      assert_equal 'kernel', response_body['results'].first['application']
      assert_equal 'dbus', response_body['results'].last['application']
      assert_equal @host_names.first, response_body['results'].first['host']
      assert_equal @host_names.last, response_body['results'].last['host']
    end

    def test_resolve_traces
      job_invocation = {"description" => "Restart Services", "id" => 1, "job_category" => "Katello"}

      Katello::HostTraceManager.expects(:resolve_traces).with([host_one_trace]).returns([job_invocation])

      put :resolve_traces, params: { :trace_ids => [host_one_trace.id] }

      assert_response :success

      body = JSON.parse(response.body)

      assert_equal [job_invocation], body
    end

    def test_resolve_traces_permission
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @destroy_permission]
      allow_restricted_user_to_see_host
      host_one_trace

      assert_protected_action(:resolve_traces, good_perms, bad_perms) do
        put :resolve_traces, params: { trace_ids: [host_one_trace.id] }
      end
    end

    #
    # Change host content source tests
    #

    def test_change_content_source
      prepare_certificates
      host = FactoryBot.create(:host, :with_content, content_view: katello_environments(:library).content_views.first,
                                                     lifecycle_environment: katello_environments(:library),
                                                     content_source: FactoryBot.create(:smart_proxy, :with_pulp3))

      lifecycle_environment = katello_environments(:dev)
      content_view = lifecycle_environment.content_views.first
      content_source = FactoryBot.create(:smart_proxy, :with_pulp3)

      put :change_content_source, params: { environment_id: lifecycle_environment.id,
                                            content_view_id: content_view.id,
                                            content_source_id: content_source.id,
                                            host_ids: [host.id] }
      assert_response :success

      assert_equal host.reload.lifecycle_environment, lifecycle_environment
      assert_equal host.reload.content_view, content_view
      assert_equal host.reload.content_source_id, content_source.id

      assert_includes @response.body, "Configure subscription-manager"
      assert_includes @response.body, content_source.pulp_content_url.to_s
    end

    def test_change_cs_ignored_hosts
      prepare_certificates
      host = FactoryBot.create(:host, :with_content, content_view: katello_environments(:library).content_views.first,
                                                     lifecycle_environment: katello_environments(:library),
                                                     content_source: FactoryBot.create(:smart_proxy, :with_pulp3))

      host2 = FactoryBot.create(:host)
      lifecycle_environment = katello_environments(:dev)
      content_view = lifecycle_environment.content_views.first
      content_source = FactoryBot.create(:smart_proxy, :with_pulp3)

      put :change_content_source, params: { environment_id: lifecycle_environment.id,
                                            content_view_id: content_view.id,
                                            content_source_id: content_source.id,
                                            host_ids: [host.id] }
      assert_response :success
      refute host2.reload.content_facet
    end

    def test_change_cs_no_hosts
      put :change_content_source
      assert_response :not_found
    end

    def test_change_cs_environment_not_found
      put :change_content_source, params: { environment_id: 0, host_ids: ::Host.all.map(&:id).to_a }
      assert_response :not_found
    end

    def test_change_cs_content_view_not_found
      put :change_content_source, params: { environment_id: katello_environments(:library).id,
                                            content_view_id: 0,
                                            host_ids: ::Host.all.map(&:id).to_a }
      assert_response :not_found
    end

    def test_change_cs_content_source_not_found
      put :change_content_source, params: { environment_id: katello_environments(:library).id,
                                            content_view_id: katello_content_views.first.id,
                                            content_source_id: 0,
                                            host_ids: ::Host.all.map(&:id).to_a }
      assert_response :not_found
    end

    private

    def prepare_certificates
      cert_path = Rails.root.join('test/static_fixtures/certificates/example.com.crt')
      Setting[:server_ca_file] = cert_path
      Setting[:ssl_ca_file] = cert_path
    end
  end
end
