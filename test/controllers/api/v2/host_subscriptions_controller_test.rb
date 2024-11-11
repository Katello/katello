# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostSubscriptionsControllerBase < ActionController::TestCase
    include Support::ForemanTasks::Task
    tests Katello::Api::V2::HostSubscriptionsController

    def models
      @host = FactoryBot.create(:host, :with_subscription, :with_operatingsystem)
      users(:restricted).update_attribute(:organizations, [@host.organization])
      users(:restricted).update_attribute(:locations, [@host.location])
      @pool = katello_pools(:pool_one)
      @entitlements = [{:pool => {:id => @pool.cp_id}, :quantity => '3'}.with_indifferent_access]
    end

    def permissions
      @view_permission = :view_hosts
      @create_permission = :create_hosts
      @update_permission = :edit_hosts
      @destroy_permission = :destroy_hosts
    end

    def backend_stubs
      Katello::Pool.any_instance.stubs(:pool_facts).returns({})
      Katello::Candlepin::Consumer.any_instance.stubs(:entitlements).returns(@entitlements)
    end

    def setup
      setup_controller_defaults_api
      setup_foreman_routes
      login_user(users(:admin))

      models
      backend_stubs
      permissions
    end
  end

  class Api::V2::HostSubscriptionsControllerTest < Api::V2::HostSubscriptionsControllerBase
    include FactImporterIsolation

    allow_transactions_for_any_importer

    def test_index
      get :index, params: { :host_id => @host.id }

      assert_response :success
      assert_template 'api/v2/host_subscriptions/index'
    end

    def test_index_bad_system
      @host = FactoryBot.create(:host)

      get :index, params: { :host_id => @host.id }

      assert_response 400
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, params: { :host_id => @host.id }
      end
    end

    def test_auto_attach
      Organization.any_instance.stubs(:simple_content_access?).returns(false)
      assert_sync_task(::Actions::Katello::Host::AutoAttachSubscriptions, @host)
      put :auto_attach, params: { :host_id => @host.id }

      assert_response :success
      assert_template 'api/v2/host_subscriptions/index'
    end

    def test_auto_attach_simple_content_access
      Organization.any_instance.stubs(:simple_content_access?).returns(true)
      put :auto_attach, params: { :host_id => @host.id }

      assert_response(400, "This host's organization is in Simple Content Access mode. Auto-attach is disabled")
    end

    def test_auto_attach_protected
      allowed_perms = [@update_permission]
      denied_perms = [@create_permission, @view_permission, @destroy_permission]

      assert_protected_action(:auto_attach, allowed_perms, denied_perms) do
        put :auto_attach, params: { :host_id => @host.id }
      end
    end

    def test_add_subscriptions
      Organization.any_instance.stubs(:simple_content_access?).returns(false)
      assert_sync_task(::Actions::Katello::Host::AttachSubscriptions) do |host, pools_with_quantities|
        assert_equal @host, host
        assert_equal 1, pools_with_quantities.count
        assert_equal @pool, pools_with_quantities[0].pool
        assert_equal [1], pools_with_quantities[0].quantities.map(&:to_i)
      end

      post :add_subscriptions, params: { :host_id => @host.id, :subscriptions => [{:id => @pool.id, :quantity => "1"}] }

      assert_response :success
      assert_template 'api/v2/host_subscriptions/index'
    end

    def test_add_subscriptions_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:add_subscriptions, allowed_perms, denied_perms) do
        post :add_subscriptions, params: { :host_id => @host.id, :subscriptions => [{:id => @pool.id, :quantity => 1}] }
      end
    end

    def test_remove_subscriptions
      assert_sync_task(::Actions::Katello::Host::RemoveSubscriptions) do |host, pools_with_quantities|
        assert_equal @host, host
        assert_equal "1", pools_with_quantities.count.to_s
        assert_equal @pool, pools_with_quantities[0].pool
        assert_equal [3], pools_with_quantities[0].quantities.map(&:to_i)
      end
      post :remove_subscriptions, params: { :host_id => @host.id, :subscriptions => [{:id => @pool.id, :quantity => '3'}] }

      assert_response :success
      assert_template 'api/v2/host_subscriptions/index'
    end

    def test_remove_subscriptions_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:remove_subscriptions, allowed_perms, denied_perms) do
        post :remove_subscriptions, params: { :host_id => @host.id, :subscriptions => [{:id => @pool.id, :quantity => 3}] }
      end
    end

    def test_create
      facts = { 'network.hostname' => @host.name}
      installed_products = [{
        'product_id' => '1',
        'product_name' => 'name',
      }]
      expected_consumer_params = {
        'type' => 'system',
        'role' => 'MyRole',
        'usage' => 'MyUsage',
        'addOns' => 'Addon1,Addon2',
        'facts' => facts,
        'installedProducts' => [{
          'productId' => '1',
          'productName' => 'name',
        }],
      }
      content_view_environment = ContentViewEnvironment.find(katello_content_view_environments(:library_default_view_environment).id)
      Resources::Candlepin::Consumer.stubs(:get)

      ::Katello::RegistrationManager.expects(:process_registration).with(expected_consumer_params, [content_view_environment]).returns(@host)
      post(:create,
        params: {
          :lifecycle_environment_id => content_view_environment.environment_id,
          :content_view_id => content_view_environment.content_view_id,
          :facts => facts,
          :installed_products => installed_products,
          :purpose_role => 'MyRole',
          :purpose_usage => 'MyUsage',
          :purpose_addons => 'Addon1,Addon2',
        }
      )

      assert_response :success
    end

    def test_create_dead_backend
      facts = { 'network.hostname' => @host.name}
      installed_products = [{
        'product_id' => '1',
        'product_name' => 'name',
      }]
      content_view_environment = ContentViewEnvironment.find(katello_content_view_environments(:library_default_view_environment).id)

      ::Katello::RegistrationManager.expects(:check_registration_services).returns(false)

      ::Katello::Host::SubscriptionFacet.expects(:find_or_create_host).never
      ::Katello::RegistrationManager.expects(:register_host).never
      post(:create, params: { :lifecycle_environment_id => content_view_environment.environment_id,
                              :content_view_id => content_view_environment.content_view_id,
                              :facts => facts, :installed_products => installed_products })

      assert_response 500
    end
  end

  class Api::V2::HostSubscriptionsProductContentTest < Api::V2::HostSubscriptionsControllerBase
    def setup
      super
      content = FactoryBot.build(:katello_content, label: 'some-content')
      pc = [FactoryBot.build(:katello_product_content, content: content)]
      ::Katello::Candlepin::Consumer.any_instance.stubs(:available_product_content).returns(pc)
      Katello::Candlepin::Consumer.any_instance.stubs(:content_overrides).returns([])
      ProductContentFinder.any_instance.stubs(:product_content).returns(pc)
    end

    def test_content_override_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:content_override, allowed_perms, denied_perms) do
        put(:content_override, params: { :host_id => @host.id, :content_label => 'some-content', :value => 1 })
      end
    end

    def test_content_override
      content_overrides = [{:content_label => 'some-content', :value => 1}]
      value = "1"
      assert_sync_task(::Actions::Katello::Host::UpdateContentOverrides) do |host, overrides, prune_invalid|
        assert_equal @host, host
        assert_equal 1, overrides.count
        assert_equal 'some-content', overrides.first.content_label
        refute prune_invalid
        assert_equal value, overrides.first.value
      end

      put :content_override, params: { :host_id => @host.id, :content_overrides => content_overrides }

      assert_response :success
      assert_template 'katello/api/v2/repository_sets/index'
    end

    def test_find_content_overrides_with_empty_string_search
      controller = ::Katello::Api::V2::HostSubscriptionsController.new
      controller.params = { :host_id => @host.id, :content_overrides => "wrong", :content_overrides_search => { :search => '' } }
      controller.instance_variable_set(:@host, @host)
      controller.send(:find_content_overrides)

      # content_overrides should be set from search param, not content_overrides param
      result = controller.instance_variable_get(:@content_overrides)
      refute_equal result, "wrong"
    end

    def test_fetch_product_content_with_respect_to_environment
      # Create fake product content and stub ProductContentFinder
      pcf = mock
      pcf.stubs(:presenter_with_overrides)

      controller = ::Katello::Api::V2::HostSubscriptionsController.new
      controller.stubs(:respond_with_template_collection)
      controller.stubs(:sync_task)
      controller.stubs(:validate_content_overrides_enabled)
      controller.stubs(:full_result_response)
      controller.instance_variable_set(:@host, @host)
      controller.instance_variable_set(:@content_overrides, [{:content_label => 'some-content', :value => 1}])

      # Actual tests that expect the correct parameters to be passed to 'content_override'
      ProductContentFinder.expects(:new).with(match_environment: true, consumable: @host.subscription_facet).returns(pcf)
      ProductContentFinder.expects(:new).with(match_environment: false, consumable: @host.subscription_facet).returns(pcf).times(3)

      # Invoke the call to the controller with a variaty of parameters
      # Try with limit_to_env enabled
      controller.params = { :host_id => @host.id, :content_overrides_search => { :search => '', :limit_to_env => true} }
      controller.send(:content_override)
      # Try with limit_to_env disabled
      controller.params = { :host_id => @host.id, :content_overrides_search => { :search => '', :limit_to_env => false} }
      controller.send(:content_override)
      # Try with limit_to_env not set - should be the same as disabled
      controller.params = { :host_id => @host.id, :content_overrides_search => { :search => ''} }
      controller.send(:content_override)
      # Try without search params - should be the same as disabled
      controller.params = { :host_id => @host.id}
      controller.send(:content_override)
    end

    def test_find_content_overrides_with_empty_string_search_limited_to_environment
      # Create Host with "fedora" and "rhel" as content
      content_view = katello_content_views(:library_dev_view)
      library = katello_environments(:library)
      activation_key = katello_activation_keys(:library_dev_staging_view_key)
      host_collection = katello_host_collections(:simple_host_collection)
      activation_key.host_collections << host_collection

      host = FactoryBot.create(:host, :with_content, :with_subscription, :content_view => content_view,
                                :lifecycle_environment => library, :organization => content_view.organization)

      # Get content_id and label of first product of host
      products = ::Katello::Content.joins(:product_contents)
                                         .where("#{Katello::ProductContent.table_name}.product_id": host.organization.products.subscribable.enabled)
      in_env_id = products.pluck(:content_id)[0]
      label = products.pluck(:label)[0]

      # Create fake product with content_id and stub ProductContentFinder
      content = FactoryBot.build(:katello_content, label: label, name: label)
      pc = [FactoryBot.build(:katello_product_content, content: content, content_id: in_env_id)]
      ProductContentFinder.any_instance.stubs(:product_content).returns(pc)

      controller = ::Katello::Api::V2::HostSubscriptionsController.new
      controller.params = { :host_id => host.id, :content_overrides_search => { :search => '', :limit_to_env => true} }
      controller.instance_variable_set(:@host, host)
      controller.send(:find_content_overrides)

      result = controller.instance_variable_get(:@content_overrides)
      assert_equal(1, result.length)
      assert_equal(label, result[0][:content_label])
    end

    def test_content_override_bulk
      content_overrides = [{:content_label => 'some-content', :value => 1}]
      expected_content_labels = content_overrides.map { |co| co[:content_label] }
      assert_sync_task(::Actions::Katello::Host::UpdateContentOverrides) do |host, overrides, prune_invalid|
        assert_equal @host, host
        assert_equal content_overrides.count, overrides.count
        refute prune_invalid
        assert_equal expected_content_labels, overrides.map(&:content_label)
      end

      put :content_override, params: { :host_id => @host.id, :content_overrides => content_overrides }

      assert_response :success
      assert_template 'katello/api/v2/repository_sets/index'
    end

    def test_content_override_accepts_string_values
      content_overrides = [{:content_label => 'some-content', :value => 1}]
      value = "1"
      assert_sync_task(::Actions::Katello::Host::UpdateContentOverrides) do |host, overrides, _|
        assert_equal @host, host
        assert_equal 1, overrides.count
        assert_equal 'some-content', overrides.first.content_label
        assert_equal value, overrides.first.value
      end

      put :content_override, params: { :host_id => @host.id, :content_overrides => content_overrides, :value => 'yes' }

      assert_response :success
    end

    # content overrides may be added before the host has access to the content
    def test_invalid_content_succeeds
      content_overrides = [{:content_label => 'wrong-content', :value => 1}]
      value = "1"
      assert_sync_task(::Actions::Katello::Host::UpdateContentOverrides) do |host, overrides, prune_invalid|
        assert_equal @host, host
        assert_equal 1, overrides.count
        assert_equal 'wrong-content', overrides.first.content_label
        refute prune_invalid
        assert_equal value, overrides.first.value
      end

      put :content_override, params: { :host_id => @host.id, :content_overrides => content_overrides, :value => value }

      assert_response :success
      assert_template 'katello/api/v2/repository_sets/index'
    end

    def test_available_release_versions
      get :available_release_versions, params: { :host_id => @host.id }

      assert_response :success
    end

    def test_enabled_repositories
      @host.content_facet = ::Katello::Host::ContentFacet.find_by(uuid: 'content_facet_one')

      get :enabled_repositories, params: { :host_id => @host.id }
      response_body_hash = JSON.parse(response.body)

      assert_equal 1, response_body_hash['results'].count
      assert_equal 'ACME_Corporation/dev/fedora_17_dev_label', response_body_hash['results'].first['relative_path']
      assert_response :success
    end

    def test_destroy
      ::Katello::RegistrationManager.expects(:unregister_host).with(@host, :unregistering => true)

      delete :destroy, params: { :host_id => @host.id }

      assert_response :success
    end
  end
end
