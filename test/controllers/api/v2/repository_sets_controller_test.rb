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
                                  organization_id: @organization.id,
                                  name: 'content-123',
                                  cp_content_id: 'content-123')
      @content_id = @content.cp_content_id
      FactoryBot.create(:katello_product_content, content: @content, product: @product)
    end

    def test_index_product
      get :index, params: { :product_id => @product.id }

      body = JSON.parse(response.body)

      assert_empty body['error']
      assert_response :success
    end

    def test_index_name
      get :index, params: { :product_id => @product.id, :name => 'foo' }

      body = JSON.parse(response.body)

      assert_empty body['error']
      assert_response :success
    end

    def test_auto_complete
      get :auto_complete_search, params: { :organization_id => @product.organization.id, :search => 'name =' }

      assert_response :success
    end

    def test_index_org_enabled
      get :index, params: { :organization_id => @organization.id, :enabled => true }

      body = JSON.parse(response.body)

      assert_empty body['error']
      assert_response :success
    end

    def test_index_org_with_active_subscription
      get :index, params: { :organization_id => @organization.id, :with_active_subscription => true }

      body = JSON.parse(response.body)

      assert_empty body['error']
      assert_response :success
    end

    def test_index_org
      get :index, params: { :organization_id => @organization.id}

      body = JSON.parse(response.body)

      assert_empty body['error']
      assert_response :success
    end

    def test_index_org_id
      get :index, params: { :organization_id => @organization.id}

      body = JSON.parse(response.body)

      assert_empty body['error']
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

    def test_available_repo_sort
      task = assert_sync_task ::Actions::Katello::RepositorySet::ScanCdn

      repo_set = lambda { |version: "", arch: "", path: ""|
        { :substitutions => { :releasever => version, :basearch => arch }, :path => path }.with_indifferent_access
      }

      expected_sort = [repo_set.call(version: nil, arch: "x86_64"),
                       repo_set.call(version: ".10", arch: "x86_64"),
                       repo_set.call(version: "7Server", arch: "x86_64"),
                       repo_set.call(version: "7.10", arch: "x86_64"),
                       repo_set.call(version: "7.9", arch: "x86_64"),
                       repo_set.call(version: "7.0", arch: "x86_64"),
                       repo_set.call(version: "5.10", arch: "x86_64"),
                       repo_set.call(version: "5.2", arch: "x86_64"),
                       repo_set.call(version: "5.1", arch: "x86_64"),
                       repo_set.call(version: "4.2", arch: "x86_64"),
                       repo_set.call(version: "5Workstation", arch: "ia64"),
                       repo_set.call(version: "5.10", arch: "ia64"),
                       repo_set.call(version: "5.11", arch: "i386"),
                       repo_set.call(version: "5.10", arch: "i386"),
                       repo_set.call(version: "5.10", arch: "")]

      task.expects(:output).at_least_once.returns(results: expected_sort.shuffle)

      get :available_repositories, params: { product_id: @product.id, id: @content_id }

      assert_equal expected_sort, JSON.parse(response.body)['results']
    end

    def test_available_repositories_protected
      allowed_perms = [@view_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @import_permission]

      assert_protected_action(:available_repositories, allowed_perms, denied_perms) do
        get :available_repositories, params: { :product_id => @product.id, :id => @content_id }
      end
    end

    def test_invalid_product_failure
      fake_product_id = 1234
      put :enable, params: { product_id: fake_product_id, id: @content_id, basearch: 'x86_64', releasever: '6Server' }

      results = JSON.parse(response.body)

      error_message = "Couldn't find product with id '#{fake_product_id}'"

      assert_response :not_found
      assert results["errors"].include? error_message
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
