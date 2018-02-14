require "katello_test_helper"

module Katello
  class Api::V2::RepositorySetsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @product = katello_products(:redhat)
    end

    def permissions
      @view_permission = :view_subscriptions
      @attach_permission = :attach_subscriptions
      @unattach_permission = :unattach_subscriptions
      @import_permission = :import_manifest
      @delete_permission = :delete_manifest
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      User.current = User.find(users(:admin).id)
      models
      permissions

      @content = FactoryBot.create(:katello_content,
                                  name: 'content-123',
                                  cp_content_id: 'content-123')
      @content_id = @content.cp_content_id
      FactoryBot.create(:katello_product_content, content: @content, product: @product)
    end

    def test_index_product
      get :index, params: { :product_id => @product.id }

      assert_response :success
    end

    def test_auto_complete
      get :auto_complete_search, params: { :organization_id => @product.organization.id, :search => 'name =' }

      assert_response :success
    end

    def test_index_org_enabled
      get :index, params: { :organization_id => @organization.id, :enabled => true }

      assert_response :success
    end

    def test_index_org
      get :index, params: { :organization_id => @organization.id}

      assert_response :success
    end

    def test_index_org_id
      get :index, params: { :organization_id => @organization.id}

      assert_response :success
    end

    def test_available_repositories
      task = assert_sync_task ::Actions::Katello::RepositorySet::ScanCdn do |product, content_id|
        product.must_equal @product
        content_id.must_equal @content_id
      end
      task.expects(:output).at_least_once.returns(results: [])

      get :available_repositories, params: { product_id: @product.id, id: @content_id }
      assert_response :success
    end

    def test_available_repositories_protected
      allowed_perms = [@view_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @import_permission]

      assert_protected_action(:available_repositories, allowed_perms, denied_perms) do
        get :available_repositories, params: { :product_id => @product.id, :id => @content_id }
      end
    end

    def test_repository_enable
      assert_sync_task ::Actions::Katello::RepositorySet::EnableRepository do |product, content, substitutions|
        product.must_equal @product
        content.cp_content_id.must_equal @content_id
        substitutions.must_equal('basearch' => 'x86_64', 'releasever' => '6Server')
      end

      put :enable, params: { product_id: @product.id, id: @content_id, basearch: 'x86_64', releasever: '6Server' }
      assert_response :success
    end

    def test_repository_enable_docker
      assert_sync_task ::Actions::Katello::RepositorySet::EnableRepository do |product, content, substitutions|
        product.must_equal @product
        content.cp_content_id.must_equal @content_id
        substitutions.must_be_empty
      end

      put :enable, params: { product_id: @product.id, id: @content_id }
      assert_response :success
    end

    def test_enable_protected
      allowed_perms = [@import_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @view_permission]

      assert_protected_action(:enable, allowed_perms, denied_perms) do
        put :enable, params: { product_id: @product.id, id: @content_id, basearch: 'x86_64', releasever: '6Server' }
      end
    end

    def test_repository_disable
      assert_sync_task ::Actions::Katello::RepositorySet::DisableRepository do |product, content, substitutions|
        product.must_equal @product
        content.cp_content_id.must_equal @content_id
        substitutions.must_equal('basearch' => 'x86_64', 'releasever' => '6Server')
      end

      put :disable, params: { product_id: @product.id, id: @content_id, basearch: 'x86_64', releasever: '6Server' }
      assert_response :success
    end

    def test_repository_disable_docker
      assert_sync_task ::Actions::Katello::RepositorySet::DisableRepository do |product, content, substitutions|
        product.must_equal @product
        content.cp_content_id.must_equal @content_id
        substitutions.must_be_empty
      end

      put :disable, params: { product_id: @product.id, id: @content_id }
      assert_response :success
    end

    def test_disable_protected
      allowed_perms = [@import_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @view_permission]

      assert_protected_action(:disable, allowed_perms, denied_perms) do
        put :disable, params: { product_id: @product.id, id: @content_id, basearch: 'x86_64', releasever: '6Server' }
      end
    end

    def test_repositories_index_with_product
      get :index, params: { product_id: @product.id }
      assert_response :success
    end
  end
end
