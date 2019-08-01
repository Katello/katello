require "katello_test_helper"

module Katello
  class Api::V2::RepositoriesControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @repository = katello_repositories(:fedora_17_unpublished)
      @rpm = katello_rpms(:one)
      @redhat_repository = katello_repositories(:rhel_6_x86_64)
      @product = katello_products(:fedora)
      @view = katello_content_views(:library_view)
      @errata = katello_errata(:security)
      @environment = katello_environments(:dev)
      @content_view_version = katello_content_view_versions(:library_view_version_1)
      @fedora_dev = katello_repositories(:fedora_17_x86_64_dev)
      @on_demand_repo = katello_repositories(:fedora_17_x86_64)
      @puppet_repo = katello_repositories(:p_forge)
      @docker_repo = katello_repositories(:busybox)
      @smart_proxy = smart_proxies(:one)
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products
      @export_permission = :export_products
    end

    def backend_stubs
      Product.any_instance.stubs(:certificate).returns(nil)
      Product.any_instance.stubs(:key).returns(nil)
      Resources::CDN::CdnResource.stubs(:ca_file_contents).returns(:nil)
      SmartProxy.stubs(:pulp_master).returns @smart_proxy
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      User.current = User.find(users(:admin).id)
      @request.env['HTTP_ACCEPT'] = 'application/json'
      models
      permissions
      backend_stubs
    end

    def test_index
      get :index, params: { :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
    end

    def test_repository_types
      get :repository_types

      assert_response :success
      body = JSON.parse(response.body)
      assert_equal RepositoryTypeManager.repository_types.size, body.size
      body.each do |repo|
        assert RepositoryTypeManager.find(repo["name"]).present?
      end
    end

    def test_repository_types_with_view_products_permission
      User.current = setup_user_with_permissions(:view_products, User.find(users(:restricted).id))
      get :repository_types
      assert_response :success
    end

    def test_creatable_repository_types
      get :repository_types, params: { :creatable => "true" }

      assert_response :success
      body = JSON.parse(response.body)
      assert_equal RepositoryTypeManager.creatable_repository_types.size, body.size
      body.each do |repo|
        assert RepositoryTypeManager.find(repo["name"]).present?
        assert RepositoryTypeManager.creatable_by_user?(repo["name"])
      end
    end

    def assert_response_ids(response, expected)
      body = JSON.parse(response.body)
      found_ids = body['results'].map { |item| item['id'] }
      refute_empty expected
      assert_equal expected.sort, found_ids.sort
    end

    def test_index_with_product_id
      ids = Repository.in_product(@product).where(:library_instance_id => nil).pluck(:id)

      response = get :index, params: { :product_id => @product.id }
      response_ids = JSON.parse(response.body)['results'].map { |repo| repo['id'] }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_equal ids.sort, response_ids.sort
    end

    def test_index_with_environment_id
      ids = @environment.repositories.pluck(:id)

      response = get :index, params: { :environment_id => @environment.id, :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_id
      ids = @view.repositories.pluck(:id)

      response = get :index, params: { :content_view_id => @view.id, :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_version_id
      version = @view.content_view_versions.first
      ids = version.repository_ids

      response = get :index, params: { :content_view_version_id => version.id, :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_version_id_archived
      version = @view.content_view_versions.first
      ids = version.archived_repos.pluck :id

      response = get :index, params: { :content_view_version_id => version.id, :organization_id => @organization.id, :archived => true }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_available_for_content_view
      ids = @view.organization.default_content_view.versions.first.repositories.pluck(:id) - @view.repositories.pluck(:id)

      response = get :index, params: { :content_view_id => @view.id, :available_for => :content_view, :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_id_and_environment_id
      ids = @fedora_dev.content_view_version.repositories.where(:environment_id => @fedora_dev.environment_id).pluck(:id)

      response = get :index, params: { :content_view_id => @fedora_dev.content_view_version.content_view_id, :environment_id => @fedora_dev.environment_id, :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_erratum_id
      ids = @errata.repositories.in_content_views([@organization.default_content_view]).pluck(:id)

      response = get :index, params: { :erratum_id => @errata.pulp_id, :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_version_id_and_environment
      repo = Repository.find(katello_repositories(:fedora_17_x86_64_dev).id)
      ids = repo.content_view_version.repositories.where(:environment_id => repo.environment.id).map(&:id)

      response = get :index, params: { :content_view_version_id => repo.content_view_version.id, :environment_id => repo.environment_id, :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    # def test_index_with_content_view_version_id_and_library
    #   # version  = @organization.default_content_view_version
    #   # ids = version.repositories.pluck(:library_instance_id).reject(&:blank?).uniq
    #   ids = @view.versions.first.repositories.pluck(:library_instance_id).reject(&:blank?).uniq
    #
    #   response = get :index, params: { :content_view_version_id => @view.versions.first.id, :organization_id => @organization.id, :library => true }
    #
    #   assert_response :success
    #   assert_template 'api/v2/repositories/index'
    #   assert_response_ids response, ids
    # end

    def test_index_with_library
      ids = @organization.default_content_view.versions.first.repositories.pluck(:id)

      response = get :index, params: { :library => true, :organization_id => @organization.id, :per_page => 100 }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_type
      ids = Repository.yum_type.where(
              :content_view_version_id => @organization.default_content_view.versions.first.id
      )
      ids = ids.pluck(:id)

      get :index, params: { :content_type => 'yum', :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_name
      ids = RootRepository.find_by(:name => katello_repositories(:fedora_17_x86_64).name).repositories.where(content_view_version: @organization.default_content_view.versions.first).pluck(:id)
      response = get :index, params: { :name => katello_repositories(:fedora_17_x86_64).name, :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, params: { :organization_id => @organization.id }
      end
    end

    def test_index_available_for_content_view_version_with_content_view
      fedora_dev_repo = katello_repositories(:fedora_17_x86_64_dev)
      response = get :index, params: { :rpm_id => @rpm.id, :content_view_id => fedora_dev_repo.content_view_version.content_view_id, :organization_id => @organization.id, :available_for => :content_view_version }
      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, [fedora_dev_repo.id]
    end

    def test_index_available_for_content_view_version
      response = get :index, params: { :rpm_id => @rpm.id, :organization_id => @organization.id, :available_for => :content_view_version }
      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, @rpm.repository_ids
    end

    def test_create
      product = mock
      product.expects(:add_repo).with({
        :label => 'Fedora_Repository',
        :name => 'Fedora Repository',
        :description => 'My Description',
        :url => 'http://www.google.com',
        :content_type => 'yum',
        :arch => 'noarch',
        :unprotected => true,
        :gpg_key => nil,
        :ssl_ca_cert => nil,
        :ssl_client_cert => nil,
        :ssl_client_key => nil}.with_indifferent_access
                                     ).returns(@repository.root)

      product.expects(:gpg_key).returns(nil)
      product.expects(:ssl_ca_cert).returns(nil)
      product.expects(:ssl_client_cert).returns(nil)
      product.expects(:ssl_client_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::CreateRoot, @repository.root)

      Product.stubs(:find).returns(product)
      post :create, params: { :name => 'Fedora Repository', :product_id => @product.id, :description => 'My Description', :url => 'http://www.google.com', :content_type => 'yum' }
      assert_response :success
      assert_template 'api/v2/common/create'
    end

    def test_create_with_empty_string_url
      product = mock
      product.expects(:add_repo).with({
        :label => 'Fedora_Repository',
        :name => 'Fedora Repository',
        :url => nil,
        :content_type => 'yum',
        :arch => 'noarch',
        :unprotected => true,
        :gpg_key => nil,
        :ssl_ca_cert => nil,
        :ssl_client_cert => nil,
        :ssl_client_key => nil}.with_indifferent_access
                                     ).returns(@repository.root)

      product.expects(:gpg_key).returns(nil)
      product.expects(:ssl_ca_cert).returns(nil)
      product.expects(:ssl_client_cert).returns(nil)
      product.expects(:ssl_client_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::CreateRoot, @repository.root)

      Product.stubs(:find).returns(product)

      post :create, params: { :name => 'Fedora Repository', :product_id => @product.id, :url => '', :content_type => 'yum' }
      assert_response :success
      assert_template 'api/v2/common/create'
    end

    def test_create_with_options
      key = GpgKey.find(katello_gpg_keys('fedora_gpg_key').id)
      cert = GpgKey.find(katello_gpg_keys('fedora_cert').id)

      product = mock
      product.expects(:add_repo).with({
        :label => 'Fedora_Repository',
        :name => 'Fedora Repository',
        :url => nil,
        :content_type => 'yum',
        :arch => 'x86_64',
        :unprotected => false,
        :ssl_ca_cert => nil,
        :ssl_client_cert => cert,
        :ssl_client_key => nil,
        :checksum_type => 'sha256',
        :download_policy => 'on_demand',
        :gpg_key => key}.with_indifferent_access
                                     ).returns(@repository.root)

      product.expects(:gpg_key).returns(key)
      product.expects(:ssl_ca_cert).returns(nil)
      product.expects(:ssl_client_cert).returns(cert)
      product.expects(:ssl_client_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::CreateRoot, @repository.root)

      Product.stubs(:find).returns(product)
      post :create, params: { :name => 'Fedora Repository', :product_id => @product.id, :url => '', :content_type => 'yum', :checksum_type => 'sha256', :unprotected => false,
                              :download_policy => 'on_demand', :ssl_client_cert => cert, :arch => 'x86_64'
                              }

      assert_response :success
      assert_template 'api/v2/common/create'
    end

    test_attributes :pid => '54108f30-d73e-46d3-ae56-cda28678e7e9'
    def test_create_with_default_download_policy
      create_task = @controller.expects(:sync_task).with do |action_class, repository|
        assert_equal ::Actions::Katello::Repository::CreateRoot, action_class
        assert_valid repository
        assert_equal Setting[:default_download_policy], repository.download_policy
      end
      create_task.returns(build_task_stub)

      post :create, params: { :name => 'Fedora Repository', :product_id => @product.id, :url => 'http://www.google.com', :content_type => 'yum' }
    end

    def run_test_individual_attribute(params)
      product = mock
      product.expects(:add_repo).returns(@repository.root)
      product.expects(:gpg_key).returns(nil)
      product.expects(:ssl_ca_cert).returns(nil)
      product.expects(:ssl_client_cert).returns(nil)
      product.expects(:ssl_client_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      yield product, @repository
      assert_sync_task(::Actions::Katello::Repository::CreateRoot, @repository.root)
      Product.stubs(:find).returns(product)
      params = {:name => 'Fedora Repository', :product_id => @product.id, :url => 'http://www.google.com', :content_type => 'yum', :unprotected => false}.merge(params)
      post :create, params: params
      assert_response :success
      assert_template 'api/v2/common/create'
    end

    def test_create_with_mirror_on_sync_true
      mirror_on_sync = true
      ENV['test'] = 'true'
      run_test_individual_attribute(:mirror_on_sync => mirror_on_sync) do |_, repo|
        repo.root.expects(:mirror_on_sync=).with(mirror_on_sync)
      end
    end

    def test_create_with_ignorable_content
      ignorable_content = ["srpm", "erratum"]
      run_test_individual_attribute(:ignorable_content => ignorable_content) do |_, repo|
        repo.root.expects(:ignorable_content=).with(ignorable_content)
      end
    end

    def test_create_with_verify_ssl_on_sync_true
      verify_ssl_on_sync = true
      run_test_individual_attribute(:verify_ssl_on_sync => verify_ssl_on_sync) do |_, repo|
        repo.root.expects(:verify_ssl_on_sync=).with(verify_ssl_on_sync)
      end
    end

    def test_create_with_username_password
      upstream_username = "genius"
      upstream_password = "genius_password"
      run_test_individual_attribute(:upstream_username => upstream_username, :upstream_password => upstream_password) do |_, repo|
        repo.root.expects(:upstream_username=).with(upstream_username)
        repo.root.expects(:upstream_password=).with(upstream_password)
      end
    end

    def test_create_with_http_proxy_policy
      run_test_individual_attribute(:http_proxy_policy => RootRepository::GLOBAL_DEFAULT_HTTP_PROXY) do |_, repo|
        repo.root.expects(:http_proxy_policy=).with(RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)
      end
    end

    def test_create_with_ignore_global_proxy_true
      run_test_individual_attribute(:ignore_global_proxy => true) do |_, repo|
        repo.root.expects(:http_proxy_policy=).with(RootRepository::NO_DEFAULT_HTTP_PROXY)
      end
    end

    def test_create_with_ignore_global_proxy_false
      run_test_individual_attribute(:ignore_global_proxy => false) do |_, repo|
        repo.root.expects(:http_proxy_policy=).with(RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)
      end
    end

    def test_create_with_http_proxy_id
      proxy = FactoryBot.create(:http_proxy)
      run_test_individual_attribute(:http_proxy_id => proxy.id) do |_, repo|
        repo.root.expects(:http_proxy_id=).with(proxy.id)
      end
    end

    def test_create_with_ostree
      repository = katello_repositories(:ostree)
      sync_depth = '123'
      sync_policy = "custom"
      product = mock
      product.expects(:add_repo).with({
        :label => 'Fedora_Repository',
        :name => 'Fedora Repository',
        :url => 'http://hub.registry.com',
        :content_type => 'ostree',
        :arch => 'noarch',
        :unprotected => true,
        :gpg_key => nil,
        :ssl_ca_cert => nil,
        :ssl_client_cert => nil,
        :ssl_client_key => nil}.with_indifferent_access
                                     ).returns(repository.root)

      product.expects(:gpg_key).returns(nil)
      product.expects(:ssl_ca_cert).returns(nil)
      product.expects(:ssl_client_cert).returns(nil)
      product.expects(:ssl_client_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      repository.root.expects(:ostree_upstream_sync_policy=).with(sync_policy)
      repository.root.expects(:ostree_upstream_sync_depth=).with(sync_depth)

      assert_sync_task(::Actions::Katello::Repository::CreateRoot, repository.root)

      Product.stubs(:find).returns(product)
      post :create, params: { :name => 'Fedora Repository', :product_id => @product.id, :url => 'http://hub.registry.com', :content_type => 'ostree', :ostree_upstream_sync_policy => sync_policy, :ostree_upstream_sync_depth => sync_depth }

      assert_response :success
      assert_template 'api/v2/common/create'
    end

    def test_create_without_label_or_name
      post :create, params: { :product_id => @product.id }
      #should raise an error along the lines of invalid content type provided
      assert_response 422
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@read_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, params: { :product_id => @product.id }
      end
    end

    def test_show
      get :show, params: { :id => @repository.id }

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_show_sync_plan_details
      sync_plan = katello_sync_plans(:sync_plan_hourly)
      sync_plan.products << @repository.product
      sync_plan.associate_recurring_logic
      sync_plan.start_recurring_logic
      get :show, params: { :id => @repository.id }

      assert_response :success
      result = JSON.parse(@response.body)

      assert_equal @repository.product.sync_plan.interval, result['product']['sync_plan']['interval']
      assert_equal @repository.product.sync_plan.name, result['product']['sync_plan']['name']
      assert_equal @repository.product.sync_plan.sync_date, result['product']['sync_plan']['sync_date']
      refute_nil @repository.product.sync_plan.next_sync
      assert_equal @repository.product.sync_plan.next_sync, result['product']['sync_plan']['next_sync']
    end

    def test_show_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, params: { :id => @repository.id }
      end
    end

    def test_update_with_gpg_key
      key = GpgKey.find(katello_gpg_keys('fedora_gpg_key').id)
      assert_sync_task(::Actions::Katello::Repository::Update) do |root, attributes|
        root.must_equal @repository.root
        attributes.to_hash.must_equal('gpg_key_id' => key.id.to_s)
      end
      put :update, params: { :id => @repository.id, :repository => {:gpg_key_id => key.id.to_s} }
      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_update_with_cert
      cert = GpgKey.find(katello_gpg_keys('fedora_cert').id)
      assert_sync_task(::Actions::Katello::Repository::Update) do |root, attributes|
        root.must_equal root
        attributes.to_hash.must_equal('ssl_ca_cert_id' => cert.id.to_s)
      end
      put :update, params: { :id => @repository.id, :repository => {:ssl_ca_cert_id => cert.id.to_s} }
      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, params: { :id => @repository.id }
      end
    end

    def test_update_with_upstream_name
      repo = katello_repositories(:busybox)
      assert_sync_task(::Actions::Katello::Repository::Update) do |_, attributes|
        attributes[:docker_upstream_name].must_equal "helloworld"
      end
      put :update, params: { :id => repo.id, :docker_upstream_name => "helloworld" }
    end

    def test_update_with_http_proxy_policy
      repo = katello_repositories(:busybox)
      assert_sync_task(::Actions::Katello::Repository::Update) do |_, attributes|
        attributes[:http_proxy_policy].must_equal RootRepository::GLOBAL_DEFAULT_HTTP_PROXY
      end
      put :update, params: { :id => repo.id, :http_proxy_policy => RootRepository::GLOBAL_DEFAULT_HTTP_PROXY }
    end

    def test_update_with_ignore_global_proxy_true
      repo = katello_repositories(:busybox)
      repo.root.update(http_proxy_policy: RootRepository::GLOBAL_DEFAULT_HTTP_PROXY)
      assert_sync_task(::Actions::Katello::Repository::Update) do |_, attributes|
        attributes[:http_proxy_policy].must_equal RootRepository::NO_DEFAULT_HTTP_PROXY
      end
      put :update, params: { :id => repo.id, :ignore_global_proxy => true }
    end

    def test_update_with_ignore_global_proxy_false
      repo = katello_repositories(:busybox)
      repo.root.update(http_proxy_policy: RootRepository::NO_DEFAULT_HTTP_PROXY)
      assert_sync_task(::Actions::Katello::Repository::Update) do |_, attributes|
        attributes[:http_proxy_policy].must_equal RootRepository::GLOBAL_DEFAULT_HTTP_PROXY
      end
      put :update, params: { :id => repo.id, :ignore_global_proxy => false }
    end

    def test_update_with_http_proxy_id
      repo = katello_repositories(:busybox)
      proxy = FactoryBot.create(:http_proxy)
      assert_sync_task(::Actions::Katello::Repository::Update) do |_, attributes|
        attributes[:http_proxy_id].must_equal proxy.id
      end
      put :update, params: { :id => repo.id, :http_proxy_id => proxy.id }
    end

    def test_update_false_download_policy
      expected_message = "must be one of the following: %s" % ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.join(', ')
      response = put :update, params: { :id => @repository.id, :download_policy => 'false' }
      body = JSON.parse(response.body)

      assert_response 422
      assert_equal(expected_message, body['errors']['download_policy'][0])
    end

    def test_update_with_upstream_sync_policy
      sync_depth = '100'
      sync_policy = "custom"
      repo = katello_repositories(:ostree)
      assert_sync_task(::Actions::Katello::Repository::Update) do |_, attributes|
        attributes[:ostree_upstream_sync_policy].must_equal sync_policy
        attributes[:ostree_upstream_sync_depth].must_equal sync_depth
      end
      put :update, params: { :id => repo.id, :ostree_upstream_sync_depth => sync_depth, :ostree_upstream_sync_policy => sync_policy }
    end

    def test_update_with_ignorable_content
      ignorable_content = ["rpm", "srpm"]
      repo = katello_repositories(:fedora_17_unpublished)
      assert_sync_task(::Actions::Katello::Repository::Update) do |_, attributes|
        attributes[:ignorable_content].must_equal ignorable_content
      end
      put :update, params: { :id => repo.id, :ignorable_content => ignorable_content }
    end

    def test_update_with_whitelist_tags
      whitelist = ["latest", "1.23"]
      assert_sync_task(::Actions::Katello::Repository::Update) do |root, attributes|
        root.must_equal @docker_repo.root
        attributes.to_hash.must_equal('docker_tags_whitelist' => whitelist)
      end
      put :update, params: { :id => @docker_repo.id, :repository => { :docker_tags_whitelist => whitelist } }
      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_update_non_docker_repo_with_whitelist_tags
      assert_sync_task(::Actions::Katello::Repository::Update) do |root, attributes|
        root.must_equal @repository.root
        attributes.to_hash.must_equal('name' => 'new name')
      end
      put :update, params: { :id => @repository.id, :repository => { name: 'new name', docker_tags_whitelist: [] } }
      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_with_whitelist_tags
      whitelist = ["latest", "1.23"]
      @docker_repo.root.docker_tags_whitelist = nil
      Product.stubs(:find).returns(@product)
      @product.expects(:add_repo).returns(@docker_repo.root)
      assert_sync_task(::Actions::Katello::Repository::CreateRoot, @docker_repo.root) do |root|
        root.must_equal @docker_repo.root
        root.docker_tags_whitelist.must_equal whitelist
      end
      post :create, params: { :name => 'busybox', :product_id => @product.id, :content_type => 'docker', :docker_upstream_name => "busybox", :docker_tags_whitelist => whitelist }
      assert_response :success
      assert_template 'api/v2/common/create'
    end

    def test_create_without_whitelist_tags
      @docker_repo.root.docker_tags_whitelist = nil
      Product.stubs(:find).returns(@product)
      @product.expects(:add_repo).returns(@docker_repo.root)
      assert_sync_task(::Actions::Katello::Repository::CreateRoot, @docker_repo.root) do |root|
        root.must_equal @docker_repo.root
        root.docker_tags_whitelist.must_equal []
      end
      post :create, params: { :name => 'busybox', :product_id => @product.id, :content_type => 'docker', :docker_upstream_name => "busybox" }
      assert_response :success
      assert_template 'api/v2/common/create'
    end

    def test_remove_content
      @repository.rpms << @rpm
      @controller.expects(:sync_task).with(::Actions::Katello::Repository::RemoveContent,
                                           @repository, [@rpm], sync_capsule: true).once.returns(::ForemanTasks::Task::DynflowTask.new)

      put :remove_content, params: { :id => @repository.id, :ids => [@rpm.pulp_id] }

      assert_response :success
    end

    def test_remove_content_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:remove_content, allowed_perms, denied_perms) do
        put :remove_content, params: { :id => @repository.id, :uuids => ['foo', 'bar'] }
      end
    end

    def test_destroy
      assert_sync_task(::Actions::Katello::Repository::Destroy) do |repo|
        repo.id == @repository.id
      end

      delete :destroy, params: { :id => @repository.id }

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@read_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, params: { :id => @repository.id }
      end
    end

    def test_republish
      assert_async_task ::Actions::Katello::Repository::MetadataGenerate do |repo, options|
        repo.id == @repository.id && options == {:force => true}
      end

      put :republish, params: { :id => @repository.id }
      assert_response :success
    end

    def test_republish_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:republish, allowed_perms, denied_perms) do
        put :republish, params: { :id => @repository.id }
      end
    end

    def test_sync
      assert_async_task ::Actions::Katello::Repository::Sync do |repo|
        repo.id == @repository.id
      end

      post :sync, params: { :id => @repository.id }
      assert_response :success
    end

    def test_sync_with_url_override
      assert_async_task ::Actions::Katello::Repository::Sync do |repo, pulp_task_id, options|
        repo.id.must_equal(@repository.id)
        assert_nil pulp_task_id
        options[:source_url].must_equal('file:///tmp/')
      end
      post :sync, params: { :id => @repository.id, :source_url => 'file:///tmp/' }
      assert_response :success
    end

    def test_sync_with_incremental_flag
      assert_async_task ::Actions::Katello::Repository::Sync do |repo, pulp_task_id, options|
        repo.id.must_equal(@repository.id)
        assert_nil pulp_task_id
        options[:source_url].must_equal('file:///tmp/')
        options[:incremental].must_equal true
      end
      post :sync, params: { :id => @repository.id, :source_url => 'file:///tmp/', :incremental => true }
      assert_response :success
    end

    def test_sync_with_bad_url_override
      post :sync, params: { :id => @repository.id, :source_url => 'file:|||tmp/' }
      assert_response 400
    end

    def test_sync_no_feed_urls
      repo = katello_repositories(:feedless_fedora_17_x86_64)
      post :sync, params: { :id => repo.id }
      assert_response 400
    end

    def test_sync_no_feed_urls_with_override
      repo = katello_repositories(:feedless_fedora_17_x86_64)
      post :sync, params: { :id => repo.id, :source_url => 'http://www.wikipedia.org' }
      assert_response :success
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@create_permission, @read_permission, @destroy_permission, @update_permission]

      assert_protected_action(:sync, allowed_perms, denied_perms) do
        post :sync, params: { :id => @repository.id }
      end
    end

    def test_upload_content
      test_document = File.join(Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
      puppet_module = Rack::Test::UploadedFile.new(test_document, '')

      assert_sync_task ::Actions::Katello::Repository::UploadFiles do |repo, files|
        repo.id == @repository.id &&
            files.size == 1 && files.first[:filename].include?("puppet_module.tar.gz")
      end

      # array
      post :upload_content, params: { :id => @repository.id, :content => [puppet_module] }
      assert_response :success

      assert_sync_task ::Actions::Katello::Repository::UploadFiles do |repo, files|
        repo.id == @repository.id &&
            files.size == 1 && files.first[:filename].include?("puppet_module.tar.gz")
      end

      # single file
      post :upload_content, params: { :id => @repository.id, :content => puppet_module }
      assert_response :success
    end

    def test_upload_content_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:upload_content, allowed_perms, denied_perms) do
        post :upload_content, params: { :id => @repository.id }
      end
    end

    def test_import_upload_ids
      uploads = [{'id' => '1'}]
      @controller.expects(:sync_task)
        .with(::Actions::Katello::Repository::ImportUpload, @repository, uploads,
              generate_metadata: false, sync_capsule: false)
        .returns(build_task_stub)

      put(:import_uploads, params: { :id => @repository.id, :upload_ids => uploads.map { |u| u['id'] }, :publish_repository => 'false', sync_capsule: 'false' })

      assert_response :success
    end

    def test_two_import_upload_ids
      uploads = [{'id' => '1'}, {'id' => '2'}]
      @controller.expects(:sync_task)
        .with(::Actions::Katello::Repository::ImportUpload, @repository, uploads,
              generate_metadata: false, sync_capsule: false)
        .returns(build_task_stub)

      put(:import_uploads, params: { :id => @repository.id, :upload_ids => uploads.map { |u| u['id'] }, :publish_repository => 'false', sync_capsule: 'false' })

      assert_response :success
    end

    def test_import_uploads
      uploads = [{'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'}]
      # make sure name gets ignored for non-file repos
      # this is yum repo. So unit keys should except name
      @controller.expects(:sync_task)
        .with(::Actions::Katello::Repository::ImportUpload, @repository, uploads,
              generate_metadata: true, sync_capsule: true)
        .returns(build_task_stub)

      put :import_uploads, params: { id: @repository.id, uploads: uploads }

      assert_response :success
    end

    def test_import_uploads_file
      # make sure name does not get ignored for file repos
      # this is yum repo. So unit keys should accept name
      file_repo = katello_repositories(:generic_file)
      uploads = [{'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'}]
      @controller.expects(:sync_task)
        .with(::Actions::Katello::Repository::ImportUpload, file_repo, uploads,
              generate_metadata: true, sync_capsule: true)
        .returns(build_task_stub)

      put :import_uploads, params: { id: file_repo, uploads: uploads }

      assert_response :success
    end

    def test_import_uploads_docker_manifest
      # make sure name does not get ignored for docker repos
      # this is docker repo. So unit keys should accept name
      uploads = [{'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'}]
      @controller.expects(:sync_task)
        .with(::Actions::Katello::Repository::ImportUpload, @docker_repo, uploads,
              generate_metadata: true, sync_capsule: true)
        .returns(build_task_stub)

      put :import_uploads, params: { id: @docker_repo.id, uploads: uploads }

      assert_response :success
    end

    def test_import_uploads_docker_tag
      uploads = [{'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test', 'digest' => 'sha256:1234'}]
      # make sure name is not ignored for docker repos
      # this is docker repo so unit keys should acccept name
      @controller.expects(:sync_task)
        .with(::Actions::Katello::Repository::ImportUpload, @docker_repo, uploads,
              generate_metadata: true, sync_capsule: true)
        .returns(build_task_stub)

      put :import_uploads, params: { id: @docker_repo.id, uploads: uploads }

      assert_response :success
    end

    def test_import_uploads_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:import_uploads, allowed_perms, denied_perms) do
        put :import_uploads, params: { :id => @repository.id, :upload_ids => [1] }
      end
    end

    def test_export
      Setting['pulp_export_destination'] = '/tmp'
      post :export, params: { :id => @repository.id }
      assert_response :success
    end

    def test_export_with_bad_date
      post :export, params: { :id => @repository.id, :since => 'November 32, 1970' }
      assert_response 400
    end

    def test_export_wrong_type
      post :export, params: { :id => @puppet_repo.id }
      assert_response 400
    end

    def test_export_on_demand
      Setting['pulp_export_destination'] = '/tmp'
      post :export, params: { :id => @on_demand_repo.id }
      assert_response 400
    end

    def test_export_with_date
      Setting['pulp_export_destination'] = '/tmp'
      post :export, params: { :id => @repository.id, :since => 'November 30, 1970' }
      assert_response :success
    end

    def test_export_with_8601_date
      Setting['pulp_export_destination'] = '/tmp'
      post :export, params: { :id => @repository.id, :since => '2010-01-01T00:00:00' }
      assert_response :success
    end

    def test_export_protected
      allowed_perms = [@export_permission]
      denied_perms = [@sync_permission, @create_permission, @read_permission,
                      @destroy_permission, @update_permission]

      assert_protected_action(:export, allowed_perms, denied_perms) do
        post :export, params: { :id => @repository.id }
      end
    end

    def test_gpg_key_content
      logout_user
      get :gpg_key_content, params: { :id => @repository.id }

      assert_response :success
      assert_equal @repository.root.gpg_key.content, response.body
    end

    def test_no_gpg_key_content
      @repository.root.gpg_key = nil
      @repository.root.save
      get :gpg_key_content, params: { :id => @repository.id }

      assert_response 404
    end
  end
end
