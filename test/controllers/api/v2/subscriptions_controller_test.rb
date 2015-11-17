# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::SubscriptionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @system = katello_systems(:simple_server)
      @products = katello_products
      @organization = get_organization
      @pool_one = katello_pools(:pool_one)
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
      login_user(User.find(users(:admin)))
      System.any_instance.stubs(:subscribe).returns(true)
      System.any_instance.stubs(:unsubscribe).returns(true)
      System.any_instance.stubs(:unsubscribe_all).returns(true)
      System.any_instance.stubs(:filtered_pools).returns([])
      System.any_instance.stubs(:releaseVer).returns(1)
      System.any_instance.stubs(:entitlements).returns([])
      System.any_instance.stubs(:find_entitlement).returns({})
      Pool.stubs(:candlepin_data).returns({})
      Pool.any_instance.stubs(:backend_data).returns({})
      Pool.any_instance.stubs(:import_lazy_attributes).returns({})

      models
      permissions
    end

    def test_system_index
      get :index, :system_id => @system.uuid, :available_for => "content_host"

      assert_response :success
      assert_template 'api/v2/subscriptions/index'
    end

    def test_index
      Pool.expects(:get_for_organization).returns(Pool.all)
      get :index, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/subscriptions/index'
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@attach_permission, @unattach_permission, @import_permission, @delete_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :organization_id => @organization.id
      end
    end

    def test_available
      get :available, :system_id => @system.uuid

      assert_response :success
      assert_template 'api/v2/subscriptions/index'
    end

    def test_available_protected
      allowed_perms = [@read_permission]
      denied_perms = [@attach_permission, @unattach_permission, @import_permission, @delete_permission]

      assert_protected_action(:available, allowed_perms, denied_perms) do
        get :available, :system_id => @system.uuid
      end
    end

    def test_create
      post :create, :system_id => @system.uuid, :subscriptions => [{:id => @pool_one.id, :quantity => 1}]

      assert_response :success
      assert_template 'katello/api/v2/subscriptions/index'
    end

    def test_create_protected
      allowed_perms = [@attach_permission]
      denied_perms = [@read_permission, @unattach_permission, @import_permission, @delete_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :system_id => @system.uuid, :subscriptions => [{:id => 'redhat', :quantity => 1}]
      end
    end

    def test_destroy
      System.any_instance.expects(:unsubscribe)
      delete :destroy, :system_id => @system.uuid, :subscriptions => [:subscription => {:id => 1}]

      assert_response :success
      assert_template 'katello/api/v2/subscriptions/index'
    end

    def test_destroy_protected
      allowed_perms = [@unattach_permission]
      denied_perms = [@read_permission, @attach_permission, @import_permission, @delete_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :system_id => @system.uuid, :subscriptions => [:subscription => {:id => 1}]
      end
    end

    def test_blank_upload
      post :upload, :organization_id => @organization.id
      assert_response 400
    end

    def test_upload
      assert_async_task ::Actions::Katello::Provider::ManifestImport do |provider, path, _force|
        assert_equal(@organization.redhat_provider.id, provider.id)
        assert_match(/\.zip$/, path)
      end
      test_document = File.join(Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
      manifest = Rack::Test::UploadedFile.new(test_document, '')
      post :upload, :organization_id => @organization.id, :content => manifest
      assert_response :success
    end

    def test_upload_protected
      allowed_perms = [@import_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @read_permission]

      assert_protected_action(:upload, allowed_perms, denied_perms) do
        post :upload, :organization_id => @organization.id
      end
    end

    def test_refresh_manfiest
      Provider.any_instance.stubs(:refresh_manifest)
      Provider.any_instance.stubs(:organization).returns(@organization)
      Organization.any_instance.stubs(:owner_details).returns("upstreamConsumer" => "JarJarBinks")
      assert_async_task(::Actions::Katello::Provider::ManifestRefresh) do |provider, upstream|
        assert_equal(@organization.redhat_provider.id, provider.id)
        assert_equal("JarJarBinks", upstream)
      end
      put :refresh_manifest, :organization_id => @organization.id
      assert_response :success
    end

    def test_refresh_protected
      allowed_perms = [@import_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @read_permission]

      assert_protected_action(:refresh_manifest, allowed_perms, denied_perms) do
        put :refresh_manifest, :organization_id => @organization.id
      end
    end

    def test_delete_manifest
      Provider.any_instance.stubs(:delete_manifest)
      assert_async_task(::Actions::Katello::Provider::ManifestDelete) do |provider|
        assert_equal(@organization.redhat_provider.id, provider.id)
      end
      post :delete_manifest, :organization_id => @organization.id
      assert_response :success
    end

    def test_delete_protected
      allowed_perms = [@delete_permission]
      denied_perms = [@attach_permission, @unattach_permission, @import_permission, @read_permission]

      assert_protected_action(:delete_manifest, allowed_perms, denied_perms) do
        post :delete_manifest, :organization_id => @organization.id
      end
    end

    def test_manifest_history
      Organization.any_instance.stubs(:manifest_history).returns(OpenStruct.new(status: 'FAILED', statusMessage: 'failed to create'))
      get :manifest_history, :organization_id => @organization.id
      assert_response :success
    end

    def test_manifest_history_protected
      allowed_perms = [@read_permission]
      denied_perms = [@attach_permission, @unattach_permission, @import_permission, @delete_permission]

      assert_protected_action(:manifest_history, allowed_perms, denied_perms) do
        get :manifest_history, :organization_id => @organization.id
      end
    end
  end
end
