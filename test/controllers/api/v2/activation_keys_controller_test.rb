# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ActivationKeysControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @activation_key = ActivationKey.find(katello_activation_keys(:simple_key).id)
      @view = katello_content_views(:library_view)
      @acme_view = katello_content_views(:acme_default)
      @library = @organization.library
      @product = katello_products(:fedora)

      ActivationKey.any_instance.stubs(:valid_content_override_label?).returns(true)
      ActivationKey.any_instance.stubs(:content_overrides).returns([])
      ActivationKey.any_instance.stubs(:products).returns([@product])
      ActivationKey.any_instance.stubs(:all_products).returns([@product])

      #@content = FactoryBot.create(:katello_content, cp_content_id: @content_id)
      #@product_content = FactoryBot.create(:katello_product_content, content: @content, product: @product)
    end

    def permissions
      @view_permission = :view_activation_keys
      @create_permission = :create_activation_keys
      @update_permission = :edit_activation_keys
      @destroy_permission = :destroy_activation_keys
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_index
      results = JSON.parse(get(:index, params: { :organization_id => @organization.id }).body)

      assert_response :success
      assert_template 'api/v2/activation_keys/index'

      assert_equal results.keys.sort, ['error', 'page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 6
      assert_includes results['results'].collect { |item| item['id'] }, @activation_key.id
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, params: { :organization_id => @organization.id }
      end
    end

    def test_index_filter_by_content_view
      results = JSON.parse(get(:index, params: { :organization_id => @organization.id, :content_view_id => @acme_view.id }).body)

      assert_response :success
      assert_equal results["results"].size, 4
    end

    def test_show
      results = JSON.parse(get(:show, params: { :id => @activation_key.id }).body)

      assert_equal results['name'], 'Simple Activation Key'

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, params: { :id => @activation_key.id }
      end
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, params: { :environment => { :id => @library.id }, :content_view => { :id => @view.id }, :activation_key => {:name => 'Key A2', :description => 'Key A2, Key to the World'} }
      end
    end

    def test_create_unlimited
      ActivationKey.any_instance.expects(:reload)
      assert_sync_task(::Actions::Katello::ActivationKey::Create) do |activation_key|
        activation_key.max_hosts.must_be_nil
      end

      post :create, params: { :organization_id => @organization.id, :activation_key => {:name => 'Unlimited Key', :unlimited_hosts => true} }

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_update
      assert_sync_task(::Actions::Katello::ActivationKey::Update) do |activation_key, activation_key_params|
        assert_equal activation_key.id, @activation_key.id
        assert_equal activation_key_params[:name], 'New Name'
        assert_equal activation_key_params[:max_hosts].to_s, "2"
        assert_equal activation_key_params[:unlimited_hosts], false
      end

      put :update, params: { :id => @activation_key.id, :organization_id => @organization.id, :activation_key => {:name => 'New Name', :max_hosts => 2} }

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms, [@organization]) do
        put :update, params: { :id => @activation_key.id, :organization_id => @organization.id, :activation_key => {:name => 'New Name'} }
      end
    end

    def test_update_limit_below_consumed
      subscription_facet1 = Host::SubscriptionFacet.find(katello_subscription_facets(:one).id)
      subscription_facet2 = Host::SubscriptionFacet.find(katello_subscription_facets(:two).id)
      @activation_key.subscription_facet_ids = [subscription_facet1.id, subscription_facet2.id]

      results = JSON.parse(put(:update, params: { :id => @activation_key.id, :organization_id => @organization.id, :activation_key => {:max_hosts => 1} }).body)

      assert_response 422
      assert_includes results['errors']['max_hosts'][0], 'cannot be lower than current usage count'
    end

    def test_destroy
      assert_sync_task(::Actions::Katello::ActivationKey::Destroy, @activation_key)
      delete :destroy, params: { :id => @activation_key.id }

      assert_response :success
      assert_template 'api/v2/common/async'
    end

    def test_destroy_object
      assert @activation_key.destroy
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@view_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms, [@organization]) do
        delete :destroy, params: { :organization_id => @organization.id, :id => @activation_key.id }
      end
    end

    def test_copy
      ActivationKey.any_instance.expects(:reload)
      @activation_key.stubs(:cp_id).returns("22222")
      @activation_key.stubs(:service_level).returns("Premium")
      @activation_key.stubs(:release_version).returns("6Server")
      @activation_key.stubs(:auto_attach).returns(false)
      @controller.instance_variable_set(:@activation_key, @activation_key)
      @controller.stubs(:find_activation_key).returns(@activation_key)

      assert_sync_task(::Actions::Katello::ActivationKey::Create)
      assert_sync_task(::Actions::Katello::ActivationKey::Update) do |_activation_key, activation_key_params|
        assert_equal activation_key_params[:service_level], @activation_key.service_level
        assert_equal activation_key_params[:release_version], @activation_key.release_version
        assert_equal activation_key_params[:auto_attach], @activation_key.auto_attach
      end
      content_overrides = [::Katello::ContentOverride.new("foo", :enabled => 1), ::Katello::ContentOverride.new("bar", :enabled => nil)]
      @activation_key.expects(:content_overrides).at_least_once.returns(content_overrides)

      ::Katello::Resources::Candlepin::ActivationKey.expects(:update_content_overrides).with do |id, hash|
        id.wont_equal(@activation_key.cp_id)
        hash.must_equal(content_overrides.map(&:to_entitlement_hash))
      end

      post :copy, params: { :id => @activation_key.id, :organization_id => @organization.id, :new_name => "NewAK" }
      assert_response :success
      assert_template 'api/v2/common/copy'
    end

    def test_copy_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @destroy_permission, @update_permission]

      assert_protected_action(:copy, allowed_perms, denied_perms) do
        post(:copy, params: { :id => @activation_key.id, :new_name => "new name" })
      end
    end

    def test_product_content_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:product_content, allowed_perms, denied_perms) do
        get(:product_content, params: { :id => @activation_key.id })
      end
    end

    def test_product_content
      response = get :product_content, params: { :id => @activation_key.id, :organization_id => @organization.id }

      refute_empty JSON.parse(response.body)['results']
      assert_response :success
      assert_template 'api/v2/activation_keys/product_content'
    end

    def test_product_content_access_modes
      ProductContentFinder.any_instance.expects(:product_content).once.returns([])

      mode_all = true
      mode_env = false
      get(:product_content, params: { :id => @activation_key.id, :content_access_mode_all => mode_all, :content_access_mode_env => mode_env })
      assert_response :success
      assert_template 'api/v2/activation_keys/product_content'
    end

    def test_content_override_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:content_override, allowed_perms, denied_perms) do
        put(:content_override, params: { :id => @activation_key.id, :content_label => 'some-content', :name => 'enabled', :value => 1 })
      end
    end

    def test_content_override
      ActivationKey.any_instance.expects(:set_content_overrides).returns(true)

      put(:content_override, params: { :id => @activation_key.id, :content_override => {:content_label => 'some-content',
                                                                                        :value => 1} })

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_content_override_bulk
      overrides = [{:content_label => 'some-content', :name => "enabled", :value => true},
                   {:content_label => 'some-content1', :value => 0},
                   {:content_label => 'some-content3', :name => "mirrorlist", :remove => true}
                  ]

      expected_content_labels = overrides.map { |o| o[:content_label] }
      expected_names = ["enabled", "enabled", "mirrorlist"]
      expected_values = ["1", "0", nil]

      ActivationKey.expects(:find).returns(@activation_key)
      @activation_key.expects(:set_content_overrides).returns(true).once.with do |params|
        params.size == overrides.size &&
          params.map(&:content_label) == expected_content_labels &&
          params.map(&:name) == expected_names &&
          params.map(&:value) == expected_values
      end

      put(:content_override, params: { :id => @activation_key.id, :content_overrides => overrides })

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_content_override_empty
      put(:content_override, params: { :id => @activation_key.id, :content_override => {:content_label => 'some-content'} })

      assert_response 400
    end

    def test_add_subscriptions_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:add_subscriptions, allowed_perms, denied_perms, [@organization]) do
        post(:add_subscriptions, params: { :organization_id => @organization.id, :id => @activation_key.id, :subscription_id => 123 })
      end
    end

    def test_remove_subscriptions_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:remove_subscriptions, allowed_perms, denied_perms, [@organization]) do
        post(:remove_subscriptions, params: { :organization_id => @organization.id, :id => @activation_key.id, :subscription_id => 123 })
      end
    end

    def test_remove_host_collections
      ActivationKey.any_instance.stubs(:save!)
      ActivationKey.any_instance.expects(:host_collection_ids=).with([])
      put(:remove_host_collections, params: { organization_id: @organization.id, id: @activation_key.id, host_collection_ids: [] })
    end
  end
end
