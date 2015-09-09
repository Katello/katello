# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ActivationKeysControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      ActivationKey.any_instance.stubs(:valid_content_label?).returns(true)
      ActivationKey.any_instance.stubs(:content_overrides).returns([])
      ActivationKey.any_instance.stubs(:products).returns([])

      @organization = get_organization
      @activation_key = ActivationKey.find(katello_activation_keys(:simple_key))
      @view = katello_content_views(:library_view)
      @library = @organization.library
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
      results = JSON.parse(get(:index, :organization_id => @organization.id).body)

      assert_response :success
      assert_template 'api/v2/activation_keys/index'

      assert_equal results.keys.sort, ['page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 6
      assert_includes results['results'].collect { |item| item['id'] }, @activation_key.id
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :organization_id => @organization.id
      end
    end

    def test_show
      results = JSON.parse(get(:show, :id => @activation_key.id).body)

      assert_equal results['name'], 'Simple Activation Key'

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :id => @activation_key.id
      end
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :environment => { :id => @library.id }, :content_view => { :id => @view.id },
             :activation_key => {:name => 'Key A2', :description => 'Key A2, Key to the World'}
      end
    end

    def test_create_unlimited
      ActivationKey.any_instance.expects(:reload)
      assert_sync_task(::Actions::Katello::ActivationKey::Create) do |activation_key|
        activation_key.max_content_hosts.must_be_nil
      end

      post :create, :organization_id => @organization.id,
                    :activation_key => {:name => 'Unlimited Key', :unlimited_content_hosts => true}

      assert_response :success
      assert_template 'katello/api/v2/common/create'
    end

    def test_update
      assert_sync_task(::Actions::Katello::ActivationKey::Update) do |activation_key, activation_key_params|
        assert_equal activation_key.id, @activation_key.id
        assert_equal activation_key_params[:name], 'New Name'
        assert_equal activation_key_params[:max_content_hosts], "2"
        assert_equal activation_key_params[:unlimited_content_hosts], false
      end

      put :update, :id => @activation_key.id, :organization_id => @organization.id,
         :activation_key => {:name => 'New Name', :max_content_hosts => 2}

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :id => @activation_key.id, :organization_id => @organization.id,
            :activation_key => {:name => 'New Name'}
      end
    end

    def test_update_limit_below_consumed
      content_host1 = System.find(katello_systems(:simple_server))
      content_host2 = System.find(katello_systems(:simple_server2))
      @activation_key.system_ids = [content_host1.id, content_host2.id]

      results = JSON.parse(put(:update, :id => @activation_key.id, :organization_id => @organization.id,
                               :activation_key => {:max_content_hosts => 1}).body)

      assert_response 422
      assert_includes results['errors']['max_content_hosts'][0], 'cannot be lower than current usage count'
    end

    def test_destroy
      assert_sync_task(::Actions::Katello::ActivationKey::Destroy, @activation_key)
      delete :destroy, :id => @activation_key.id

      assert_response :success
      assert_template 'api/v2/common/async'
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@view_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :organization_id => @organization.id, :id => @activation_key.id
      end
    end

    def test_copy_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @destroy_permission, @update_permission]

      assert_protected_action(:copy, allowed_perms, denied_perms) do
        post(:copy, :id => @activation_key.id, :new_name => "new name")
      end
    end

    def test_product_content_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:product_content, allowed_perms, denied_perms) do
        get(:product_content, :id => @activation_key.id)
      end
    end

    def test_product_content
      get :product_content, :id => @activation_key.id, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/activation_keys/product_content'
    end

    def test_content_override_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:content_override, allowed_perms, denied_perms) do
        put(:content_override, :id => @activation_key.id, :content_label => 'some-content',
            :name => 'enabled', :value => 1)
      end
    end

    def test_content_override
      ActivationKey.any_instance.expects(:set_content_override).returns(true)

      put(:content_override, :id => @activation_key.id, :content_override => {:content_label => 'some-content',
                                                                              :name => 'enabled', :value => 1})

      assert_response :success
      assert_template 'api/v2/activation_keys/show'
    end

    def test_content_override_empty
      put(:content_override, :id => @activation_key.id, :content_override => {:content_label => 'some-content', :name => 'enabled'})

      assert_response 400
    end

    def test_add_subscriptions_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:add_subscriptions, allowed_perms, denied_perms) do
        post(:add_subscriptions, :organization_id => @organization.id, :id => @activation_key.id, :subscription_id => 123)
      end
    end

    def test_remove_subscriptions_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:remove_subscriptions, allowed_perms, denied_perms) do
        post(:remove_subscriptions, :organization_id => @organization.id, :id => @activation_key.id, :subscription_id => 123)
      end
    end
  end
end
