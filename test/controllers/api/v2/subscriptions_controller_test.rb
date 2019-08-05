# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::SubscriptionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @products = katello_products
      @organization = get_organization
    end

    def permissions
      @read_permission = :view_subscriptions
      @attach_permission = :attach_subscriptions
      @unattach_permission = :unattach_subscriptions
      @import_permission = :import_manifest
      @delete_permission = :delete_manifest
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      Pool.stubs(:candlepin_data).returns({})
      Pool.stubs(:get_for_owner).returns([])
      Pool.any_instance.stubs(:import_data).returns(true)
      Pool.any_instance.stubs(:backend_data).returns({})
      Pool.any_instance.stubs(:import_lazy_attributes).returns({})
      ActivationKey.any_instance.stubs(:get_key_pools).returns([{'id' => 'abc123', amount: 4}])

      models
      permissions
    end

    def test_index
      Pool.expects(:get_for_organization).returns(Pool.all)
      get :index, params: { :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/subscriptions/index'
    end

    def test_index_csv
      Pool.expects(:get_for_organization).returns(Pool.all)
      get :index, params: {:format => 'csv', :organization_id => @organization.id }
      assert_response :success
      assert_equal "text/csv; charset=utf-8", response.headers["Content-Type"]
      assert_equal "no-cache", response.headers["Cache-Control"]
      assert_equal "attachment; filename=\"#{@organization.label}-subscriptions-#{Date.today}.csv\"",
        response.headers["Content-Disposition"]
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@attach_permission, @unattach_permission, @import_permission, @delete_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, params: { :organization_id => @organization.id }
      end
    end

    def test_include_permissions
      get :index, params: {
        organization_id: @organization.id,
        include_permissions: true
      }
      nodes = JSON.parse(response.body).keys
      expected_permissions = %w[
        can_manage_subscription_allocations
        can_import_manifest
        can_delete_manifest
        can_edit_organizations
      ]
      expected_permissions.each do |permission|
        assert_includes(nodes, permission)
      end
    end

    def test_index_with_activation_key_id
      activation_key = katello_activation_keys(:dev_key)
      get :index, params: { activation_key_id: activation_key.id }
      pool = JSON.parse(@response.body)['results'].find { |p| p['cp_id'] == 'abc123' }
      assert_equal(4, pool['quantity_attached'])
      assert_response :success
      assert_template 'api/v2/subscriptions/index'
    end

    def test_blank_upload
      post :upload, params: { :organization_id => @organization.id }
      assert_response 400
    end

    def test_upload
      assert_async_task ::Actions::Katello::Organization::ManifestImport do |org, path, _force|
        assert_equal(@organization, org)
        assert_match(/\.zip$/, path)
      end
      test_document = File.join(Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
      manifest = Rack::Test::UploadedFile.new(test_document, '')
      post :upload, params: { :organization_id => @organization.id, :content => manifest }
      assert_response :success
    end

    def test_upload_protected
      allowed_perms = [@import_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @read_permission]

      assert_protected_action(:upload, allowed_perms, denied_perms, [@organization]) do
        post :upload, params: { :organization_id => @organization.id }
      end
    end

    def test_refresh_manfiest
      assert_async_task(::Actions::Katello::Organization::ManifestRefresh) do |organization|
        assert_equal(@organization, organization)
      end
      put :refresh_manifest, params: { :organization_id => @organization.id }
      assert_response :success
    end

    def test_refresh_protected
      allowed_perms = [@import_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @read_permission]

      assert_protected_action(:refresh_manifest, allowed_perms, denied_perms, [@organization]) do
        put :refresh_manifest, params: { :organization_id => @organization.id }
      end
    end

    def test_refresh_disconnected
      Setting["content_disconnected"] = true
      put :refresh_manifest, params: { :organization_id => @organization.id }
      assert_response :bad_request
    end

    def test_delete_manifest
      assert_async_task(::Actions::Katello::Organization::ManifestDelete) do |org|
        assert_equal @organization, org
      end
      post :delete_manifest, params: { :organization_id => @organization.id }
      assert_response :success
    end

    def test_delete_protected
      allowed_perms = [@delete_permission]
      denied_perms = [@attach_permission, @unattach_permission, @import_permission, @read_permission]

      assert_protected_action(:delete_manifest, allowed_perms, denied_perms, [@organization]) do
        post :delete_manifest, params: { :organization_id => @organization.id }
      end
    end

    def test_manifest_history
      Organization.any_instance.stubs(:manifest_history).returns(OpenStruct.new(status: 'FAILED', statusMessage: 'failed to create'))
      get :manifest_history, params: { :organization_id => @organization.id }
      assert_response :success
    end

    def test_manifest_history_protected
      allowed_perms = [@read_permission]
      denied_perms = [@attach_permission, @unattach_permission, @import_permission, @delete_permission]

      assert_protected_action(:manifest_history, allowed_perms, denied_perms, [@organization]) do
        get :manifest_history, params: { :organization_id => @organization.id }
      end
    end
  end
end
