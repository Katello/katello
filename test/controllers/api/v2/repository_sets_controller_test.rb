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

      @content = OpenStruct.new(name: 'content-123', id: 'content-123', 'displayable?': true)

      Product.any_instance.stubs(productContent: [OpenStruct.new(content: @content)])
    end

    def test_available_repositories
      task = assert_sync_task ::Actions::Katello::RepositorySet::ScanCdn do |product, content_id|
        product.must_equal @product
        content_id.must_equal @content.id
      end
      task.expects(:output).at_least_once.returns(results: [])

      get :available_repositories, product_id: @product.id, id: @content.id
      assert_response :success
    end

    def test_available_repositories_protected
      allowed_perms = [@view_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @import_permission]

      assert_protected_action(:available_repositories, allowed_perms, denied_perms) do
        get :available_repositories, :product_id => @product.id, :id => @content.id
      end
    end

    def test_repository_enable
      assert_sync_task ::Actions::Katello::RepositorySet::EnableRepository do |product, content, substitutions|
        product.must_equal @product
        content.id.must_equal @content.id
        substitutions.must_equal('basearch' => 'x86_64', 'releasever' => '6Server')
      end

      put :enable,
          product_id: @product.id,
          id: @content.id,
          basearch: 'x86_64', releasever: '6Server'
      assert_response :success
    end

    def test_repository_enable_docker
      assert_sync_task ::Actions::Katello::RepositorySet::EnableRepository do |product, content, substitutions|
        product.must_equal @product
        content.id.must_equal @content.id
        substitutions.must_be_empty
      end

      put :enable,
          product_id: @product.id,
          id: @content.id
      assert_response :success
    end

    def test_enable_protected
      allowed_perms = [@import_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @view_permission]

      assert_protected_action(:enable, allowed_perms, denied_perms) do
        put :enable,
            product_id: @product.id,
            id: @content.id,
            basearch: 'x86_64', releasever: '6Server'
      end
    end

    def test_repository_disable
      assert_sync_task ::Actions::Katello::RepositorySet::DisableRepository do |product, content, substitutions|
        product.must_equal @product
        content.id.must_equal @content.id
        substitutions.must_equal('basearch' => 'x86_64', 'releasever' => '6Server')
      end

      put :disable,
          product_id: @product.id,
          id: @content.id,
          basearch: 'x86_64', releasever: '6Server'
      assert_response :success
    end

    def test_repository_disable_docker
      assert_sync_task ::Actions::Katello::RepositorySet::DisableRepository do |product, content, substitutions|
        product.must_equal @product
        content.id.must_equal @content.id
        substitutions.must_be_empty
      end

      put :disable,
          product_id: @product.id,
          id: @content.id
      assert_response :success
    end

    def test_disable_protected
      allowed_perms = [@import_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @view_permission]

      assert_protected_action(:disable, allowed_perms, denied_perms) do
        put :disable,
            product_id: @product.id,
            id: @content.id,
            basearch: 'x86_64', releasever: '6Server'
      end
    end

    def test_repositories_index_with_product
      get :index, product_id: @product.id
      assert_response :success
    end

    def test_repositories_index_without_product
      Organization.stubs(:current).returns(@organization)
      @organization.products.stubs(:enabled).returns([@product])
      Product.any_instance.stubs(available_content: [OpenStruct.new(content: @content)])
      get :index
      assert_response :success
    end
  end
end
