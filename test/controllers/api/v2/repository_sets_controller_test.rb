require "katello_test_helper"

module Katello
  class Api::V2::RepositorySetsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @product = katello_products(:redhat)
    end

    def permissions
      @view_permission = :view_products
      @edit_permission = :edit_products
      @attach_permission = :attach_subscriptions
      @unattach_permission = :unattach_subscriptions
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

    def setup_activation_keys
      @activation_key = ActivationKey.find(katello_activation_keys(:simple_key).id)

      ActivationKey.any_instance.stubs(:valid_content_override_label?).returns(true)
      ActivationKey.any_instance.stubs(:content_overrides).returns([])
      ActivationKey.any_instance.stubs(:products).returns(Product.where(id: @product.id))
      ActivationKey.any_instance.stubs(:all_products).returns(Product.where(id: @product.id))
    end

    def setup_hosts
      @host = hosts(:one)
      users(:restricted).update_attribute(:organizations, [@host.organization])
      users(:restricted).update_attribute(:locations, [@host.location])
      Katello::Candlepin::Consumer.any_instance.stubs(:content_overrides).returns([])
      ProductContentFinder.any_instance.stubs(:product_content).returns(::Katello::ProductContent.all)
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

    def test_index_org_with_custom
      get :index, params: { :organization_id => @organization.id, :with_custom => true }

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

    def test_index_protected_product
      allowed_perms = [:view_products]
      assert_protected_action(:index, allowed_perms, []) do
        get(:index, params: { :product_id => @product.id })
      end
    end

    def test_index_protected_activation_keys
      setup_activation_keys
      allowed_perms = [:view_activation_keys]

      assert_protected_action(:index, allowed_perms, []) do
        get(:index, params: { :activation_key_id => @activation_key.id })
      end
    end

    def test_index_activation_keys
      setup_activation_keys
      response = get :index, params: { :activation_key_id => @activation_key.id }

      refute_empty JSON.parse(response.body)['results']
      assert_response :success
      assert_template 'katello/api/v2/repository_sets/index'
    end

    def test_product_content_access_modes_activation_keys
      setup_activation_keys
      ProductContentFinder.any_instance.expects(:product_content).once.returns(ProductContent.none)

      mode_all = true
      mode_env = false
      get(:index, params: { :activation_key_id => @activation_key.id, :content_access_mode_all => mode_all, :content_access_mode_env => mode_env })
      assert_response :success
      assert_template 'katello/api/v2/repository_sets/index'
    end

    def test_index_protected_content_hosts
      setup_hosts
      allowed_perms = [:view_hosts]

      assert_protected_action(:index, allowed_perms, []) do
        get(:index, params: { :host_id => @host.id })
      end
    end

    def test_index_content_hosts
      setup_hosts
      response = get :index, params: { :host_id => @host.id }
      refute_empty JSON.parse(response.body)['results']
      assert_response :success
      assert_template 'katello/api/v2/repository_sets/index'
    end

    def test_product_content_access_modes_hosts
      setup_hosts
      ProductContentFinder.any_instance.expects(:product_content).once.returns(ProductContent.none)

      mode_all = true
      mode_env = false
      get(:index, params: { :host_id => @host.id, :content_access_mode_all => mode_all, :content_access_mode_env => mode_env })
      assert_response :success
      assert_template 'katello/api/v2/repository_sets/index'
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

    def test_available_repositories_no_product
      #reset the id of the product_content, as factorybot seems to use the same id as well as content_id
      # not exposing the bug
      @content.reload.product_contents.first.update(:id => Katello::ProductContent.maximum(:id) + 1000)
      task = assert_sync_task ::Actions::Katello::RepositorySet::ScanCdn do |product, content_id|
        product.must_equal @product
        content_id.must_equal @content_id
      end
      task.expects(:output).at_least_once.returns(results: [])

      get :available_repositories, params: {id: @content_id, organization_id: @product.organization_id }
      assert_response :success
    end

    def test_hides_kickstart_repos
      task = assert_sync_task ::Actions::Katello::RepositorySet::ScanCdn

      ks_path = '/foobar/kickstart/'
      ks_7server = { :substitutions => { :releasever => '7Server', :basearch => '' }, :path => ks_path }.with_indifferent_access
      ks_7_1 = { :substitutions => { :releasever => '7.1', :basearch => '' }, :path => ks_path }.with_indifferent_access
      ks_8_0 = { :substitutions => { :releasever => '8.0', :basearch => ''}, :path => ks_path }.with_indifferent_access
      ks_8 = { :substitutions => { :releasever => '8', :basearch => '' }, :path => ks_path }.with_indifferent_access
      rpm_8 = { :substitutions => { :releasever => '8', :basearch => '' }, :path => '/foobar/' }.with_indifferent_access
      nil_release = { :substitutions => { :releasever => nil, :basearch => '' }, :path => ks_path }.with_indifferent_access

      task.expects(:output).at_least_once.returns(results: [ks_7server, ks_7_1, ks_8_0, ks_8, rpm_8, nil_release])

      get :available_repositories, params: { product_id: @product.id, id: @content_id }
      results = JSON.parse(response.body)['results']

      assert_includes results, ks_7_1
      assert_includes results, ks_8_0
      assert_includes results, rpm_8
      assert_includes results, nil_release

      refute_includes results, ks_7server
      refute_includes results, ks_8
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
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission]

      assert_protected_action(:available_repositories, allowed_perms, denied_perms) do
        get :available_repositories, params: { :product_id => @product.id, :id => @content_id }
      end
    end

    def test_invalid_product_failure
      fake_product_id = 1234
      put :enable, params: { product_id: fake_product_id, id: @content_id, basearch: 'x86_64', releasever: '6Server' }

      results = JSON.parse(response.body)

      error_message = "Could not find product resource with id #{fake_product_id}. Potential missing permissions: edit_products"

      assert_response :not_found
      assert_includes results["errors"], error_message
    end

    def test_repository_enable
      assert_sync_task ::Actions::Katello::RepositorySet::EnableRepository do |product, content, substitutions|
        product.must_equal @product
        assert_equal @content_id, content.cp_content_id
        substitutions.must_equal('basearch' => 'x86_64', 'releasever' => '6Server')
      end

      put :enable, params: { product_id: @product.id, id: @content_id, basearch: 'x86_64', releasever: '6Server' }
      assert_response :success
    end

    def test_repository_enable_docker
      assert_sync_task ::Actions::Katello::RepositorySet::EnableRepository do |product, content, substitutions|
        product.must_equal @product
        assert_equal @content_id, content.cp_content_id
        substitutions.must_be_empty
      end

      put :enable, params: { product_id: @product.id, id: @content_id }
      assert_response :success
    end

    def test_enable_protected
      allowed_perms = [@edit_permission]
      denied_perms = [@attach_permission, @unattach_permission, @delete_permission, @view_permission]

      assert_protected_action(:enable, allowed_perms, denied_perms) do
        put :enable, params: { product_id: @product.id, id: @content_id, basearch: 'x86_64', releasever: '6Server' }
      end
    end

    def test_repository_disable
      assert_sync_task ::Actions::Katello::RepositorySet::DisableRepository do |product, content, substitutions|
        product.must_equal @product
        assert_equal @content_id, content.cp_content_id
        substitutions.must_equal('basearch' => 'x86_64', 'releasever' => '6Server')
      end

      put :disable, params: { product_id: @product.id, id: @content_id, basearch: 'x86_64', releasever: '6Server' }
      assert_response :success
    end

    def test_repository_disable_docker
      assert_sync_task ::Actions::Katello::RepositorySet::DisableRepository do |product, content, substitutions|
        product.must_equal @product
        assert_equal @content_id, content.cp_content_id
        substitutions.must_be_empty
      end

      put :disable, params: { product_id: @product.id, id: @content_id }
      assert_response :success
    end

    def test_disable_protected
      allowed_perms = [@edit_permission]
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
