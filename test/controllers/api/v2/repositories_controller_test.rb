require "katello_test_helper"

module Katello
  # rubocop:disable Metrics/ClassLength
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
      get :index, :organization_id => @organization.id

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

    def test_creatable_repository_types
      get :repository_types, :creatable => "true"

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
      ids = Repository.where(:product_id => @product.id, :library_instance_id => nil).pluck(:id)

      response = get :index, :product_id => @product.id
      response_ids = JSON.parse(response.body)['results'].map { |repo| repo['id'] }

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_equal response_ids.sort, ids.sort
    end

    def test_index_with_environment_id
      ids = @environment.repositories.pluck(:id)

      response = get :index, :environment_id => @environment.id, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_id
      ids = @view.repositories.pluck(:id)

      response = get :index, :content_view_id => @view.id, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_version_id
      version = @view.content_view_versions.first
      ids = version.repository_ids

      response = get :index, :content_view_version_id => version.id, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_available_for_content_view
      ids = @view.organization.default_content_view.versions.first.repositories.pluck(:id) - @view.repositories.pluck(:id)

      response = get :index, :content_view_id => @view.id, :available_for => :content_view, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_id_and_environment_id
      ids = @fedora_dev.content_view_version.repositories.pluck(:id)

      response =  get :index, :content_view_id => @fedora_dev.content_view_version.content_view_id, :environment_id => @fedora_dev.environment_id,
                  :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_erratum_id
      ids = @errata.repositories.in_content_views([@organization.default_content_view]).pluck(:id)

      response = get :index, :erratum_id => @errata.uuid, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_version_id_and_environment
      repo = Repository.find(katello_repositories(:fedora_17_x86_64_dev).id)
      ids = repo.content_view_version.repository_ids

      response =  get :index, :content_view_version_id => repo.content_view_version.id,
                  :environment_id => repo.environment_id,
                  :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_view_version_id_and_library
      ids = @view.versions.first.repositories.pluck(:library_instance_id).reject(&:blank?).uniq
      response = get :index, :content_view_version_id => @view.versions.first.id, :organization_id => @organization.id, :library => true

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_library
      ids = @organization.default_content_view.versions.first.repositories.pluck(:id)

      response = get :index, :library => true, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_content_type
      ids = Repository.where(
              :content_type => 'yum',
              :content_view_version_id => @organization.default_content_view.versions.first.id
      )
      ids = ids.pluck(:id)

      get :index, :content_type => 'yum', :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_with_name
      ids = Repository.where(:name => katello_repositories(:fedora_17_x86_64).name, :library_instance_id => nil).pluck(:id)

      response = get :index, :name => katello_repositories(:fedora_17_x86_64).name, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
      assert_response_ids response, ids
    end

    def test_index_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :organization_id => @organization.id
      end
    end

    def test_create
      product = mock
      product.expects(:add_repo).with(
        'Fedora_Repository',
        'Fedora Repository',
        'http://www.google.com',
        'yum',
        true,
        nil,
        nil,
        nil
      ).returns(@repository)

      product.expects(:gpg_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stubs(:find).returns(product)
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.id,
                    :url => 'http://www.google.com',
                    :content_type => 'yum'

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_with_empty_string_url
      product = mock
      product.expects(:add_repo).with(
        'Fedora_Repository',
        'Fedora Repository',
        nil,
        'yum',
        true,
        nil,
        nil,
        nil
      ).returns(@repository)

      product.expects(:gpg_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stubs(:find).returns(product)

      post :create, :name => 'Fedora Repository',
                      :product_id => @product.id,
                      :url => '',
                      :content_type => 'yum'

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_with_gpg_key
      key = GpgKey.find(katello_gpg_keys('fedora_gpg_key').id)
      product = mock
      product.expects(:add_repo).with(
        'Fedora_Repository',
        'Fedora Repository',
        'http://www.google.com',
        'yum',
        true,
        key,
        nil,
        nil
      ).returns(@repository)

      product.expects(:gpg_key).returns(key)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stubs(:find).returns(product)

      post :create, :name => 'Fedora Repository',
                    :product_id => @product.id,
                    :url => 'http://www.google.com',
                    :content_type => 'yum'

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_with_checksum
      product = mock
      product.expects(:add_repo).with(
        'Fedora_Repository',
        'Fedora Repository',
        nil,
        'yum',
        true,
        nil,
        'sha256',
        nil
      ).returns(@repository)

      product.expects(:gpg_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stubs(:find).returns(product)
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.id,
                    :url => '',
                    :content_type => 'yum',
                    :checksum_type => 'sha256'

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_with_download_policy
      product = mock
      product.expects(:add_repo).with(
        'Fedora_Repository',
        'Fedora Repository',
        nil,
        'yum',
        true,
        nil,
        nil,
        'on_demand'
      ).returns(@repository)

      product.expects(:gpg_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stubs(:find).returns(product)
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.id,
                    :url => '',
                    :content_type => 'yum',
                    :download_policy => 'on_demand'

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_with_protected_true
      product = mock
      product.expects(:add_repo).with(
        'Fedora_Repository',
        'Fedora Repository',
        'http://www.google.com',
        'yum',
        false,
        nil,
        nil,
        nil
      ).returns(@repository)

      product.expects(:gpg_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stubs(:find).returns(product)
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.id,
                    :url => 'http://www.google.com',
                    :content_type => 'yum',
                    :unprotected => false

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_with_mirror_on_sync_true
      mirror_on_sync = true
      product = mock
      product.expects(:add_repo).with(
        'Fedora_Repository',
        'Fedora Repository',
        'http://www.google.com',
        'yum',
        false,
        nil,
        nil,
        nil
      ).returns(@repository)

      product.expects(:gpg_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      @repository.expects(:mirror_on_sync=).with(mirror_on_sync)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stubs(:find).returns(product)
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.id,
                    :url => 'http://www.google.com',
                    :content_type => 'yum',
                    :unprotected => false,
                    :mirror_on_sync => mirror_on_sync
      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_with_protected_docker
      product = mock
      product.expects(:add_repo).with(
        'Fedora_Repository',
        'Fedora Repository',
        'http://hub.registry.com',
        'docker',
        true,
        nil,
        nil,
        nil
      ).returns(@repository)

      product.expects(:gpg_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stubs(:find).returns(product)
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.id,
                    :url => 'http://hub.registry.com',
                    :content_type => 'docker',
                    :docker_upstream_name => "busybox"

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_with_ostree
      product = mock
      product.expects(:add_repo).with(
        'Fedora_Repository',
        'Fedora Repository',
        'http://hub.registry.com',
        'ostree',
        true,
        nil,
        nil,
        nil
      ).returns(@repository)

      product.expects(:gpg_key).returns(nil)
      product.expects(:organization).returns(@organization)
      product.expects(:redhat?).returns(false)

      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stubs(:find).returns(product)
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.id,
                    :url => 'http://hub.registry.com',
                    :content_type => 'ostree'

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_create_without_label_or_name
      post :create, :product_id => @product.id
      #should raise an error along the lines of invalid content type provided
      assert_response 422
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@read_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :product_id => @product.id
      end
    end

    def test_show
      get :show, :id => @repository.id

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_show_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :id => @repository.id
      end
    end

    def test_update
      key = GpgKey.find(katello_gpg_keys('fedora_gpg_key').id)
      assert_sync_task(::Actions::Katello::Repository::Update) do |repo, attributes|
        repo.must_equal @repository
        attributes.must_equal('gpg_key_id' => "#{key.id}")
      end
      put :update, :id => @repository.id, :repository => {:gpg_key_id => key.id}
      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, :id => @repository.id
      end
    end

    def test_update_with_upstream_name
      repo = katello_repositories(:busybox)
      assert_sync_task(::Actions::Katello::Repository::Update) do |_, attributes|
        attributes[:docker_upstream_name] = "helloworld"
      end
      put :update, :id => repo.id, :docker_upstream_name => "helloworld"
    end

    def test_update_false_download_policy
      expected_message = "must be one of the following: %s" % ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.join(', ')
      response = put :update, :id => @repository.id, :download_policy => 'false'
      body = JSON.parse(response.body)

      assert_response 422
      assert_equal(expected_message, body['errors']['download_policy'][0])
    end

    def test_remove_content
      @repository.rpms << @rpm
      @controller.expects(:sync_task).with(::Actions::Katello::Repository::RemoveContent,
                                           @repository, [@rpm]).once.returns(::ForemanTasks::Task.new)

      put :remove_content, :id => @repository.id, :ids => [@rpm.uuid]

      assert_response :success
    end

    def test_remove_content_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:remove_content, allowed_perms, denied_perms) do
        put :remove_content, :id => @repository.id, :uuids => ['foo', 'bar']
      end
    end

    def test_destroy
      assert_sync_task(::Actions::Katello::Repository::Destroy) do |repo|
        repo.id == @repository.id
      end

      delete :destroy, :id => @repository.id

      assert_response :success
    end

    def test_destroy_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@read_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :id => @repository.id
      end
    end

    def test_sync
      assert_async_task ::Actions::Katello::Repository::Sync do |repo|
        repo.id == @repository.id
      end

      post :sync, :id => @repository.id
      assert_response :success
    end

    def test_sync_with_url_override
      assert_async_task ::Actions::Katello::Repository::Sync do |repo, pulp_task_id, source_url|
        repo.id.must_equal(@repository.id)
        pulp_task_id.must_equal(nil)
        source_url.must_equal('file:///tmp/')
      end
      post :sync, :id => @repository.id, :source_url => 'file:///tmp/'
      assert_response :success
    end

    def test_sync_with_incremental_flag
      assert_async_task ::Actions::Katello::Repository::Sync do |repo, pulp_task_id, source_url, incremental|
        repo.id.must_equal(@repository.id)
        pulp_task_id.must_equal(nil)
        source_url.must_equal('file:///tmp/')
        incremental.must_equal true
      end
      post :sync, :id => @repository.id, :source_url => 'file:///tmp/', :incremental => true
      assert_response :success
    end

    def test_sync_with_bad_url_override
      post :sync, :id => @repository.id, :source_url => 'file:|||tmp/'
      assert_response 400
    end

    def test_sync_no_feed_urls
      repo = katello_repositories(:feedless_fedora_17_x86_64)
      post :sync, :id => repo.id
      assert_response 400
    end

    def test_sync_no_feed_urls_with_override
      repo = katello_repositories(:feedless_fedora_17_x86_64)
      post :sync, :id => repo.id, :source_url => 'http://www.wikipedia.org'
      assert_response :success
    end

    def test_sync_complete
      token = 'imalittleteapotshortandstout'
      SETTINGS[:katello][:post_sync_url] = "http://foo.com/foo?token=#{token}"
      Repository.stubs(:where).returns([@repository])

      assert_async_task ::Actions::Katello::Repository::Sync do |repo, task_id|
        repo.id == @repository.id && task_id == '1234'
      end

      post(:sync_complete,
           :token => token,
           :payload => {:repo_id => @repository.pulp_id},
           :call_report => {:task_id => '1234'})
      assert_response :success
    end

    def test_sync_complete_bad_token
      token = 'super_secret'
      SETTINGS[:katello][:post_sync_url] = "http://foo.com/foo?token=attacker_key"
      post :sync_complete, :token => token, :payload => {:repo_id => @repository.pulp_id}, :call_report => {}

      assert_response 403
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@create_permission, @read_permission, @destroy_permission, @update_permission]

      assert_protected_action(:sync, allowed_perms, denied_perms) do
        post :sync, :id => @repository.id
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
      post :upload_content, :id => @repository.id, :content => [puppet_module]
      assert_response :success

      assert_sync_task ::Actions::Katello::Repository::UploadFiles do |repo, files|
        repo.id == @repository.id &&
            files.size == 1 && files.first[:filename].include?("puppet_module.tar.gz")
      end

      # single file
      post :upload_content, :id => @repository.id, :content => puppet_module
      assert_response :success
    end

    def test_upload_content_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:upload_content, allowed_perms, denied_perms) do
        post :upload_content, :id => @repository.id
      end
    end

    def test_import_uploads
      assert_sync_task ::Actions::Katello::Repository::ImportUpload, @repository, '1'

      put :import_uploads, :id => @repository.id, :upload_ids => [1]

      assert_response :success
    end

    def test_import_uploads_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:import_uploads, allowed_perms, denied_perms) do
        put :import_uploads, :id => @repository.id, :upload_ids => [1]
      end
    end

    def test_export
      Setting['pulp_export_destination'] = '/tmp'
      post :export, :id => @repository.id
      assert_response :success
    end

    def test_export_with_bad_date
      post :export, :id => @repository.id, :since => 'November 32, 1970'
      assert_response 400
    end

    def test_export_with_date
      Setting['pulp_export_destination'] = '/tmp'
      post :export, :id => @repository.id, :since => 'November 30, 1970'
      assert_response :success
    end

    def test_export_with_8601_date
      Setting['pulp_export_destination'] = '/tmp'
      post :export, :id => @repository.id, :since => '2010-01-01T00:00:00'
      assert_response :success
    end

    def test_export_protected
      allowed_perms = [@export_permission]
      denied_perms = [@sync_permission, @create_permission, @read_permission,
                      @destroy_permission, @update_permission]

      assert_protected_action(:export, allowed_perms, denied_perms) do
        post :export, :id => @repository.id
      end
    end

    def test_gpg_key_content
      get :gpg_key_content, :id => @repository.id

      assert_response :success
      assert_equal @repository.gpg_key.content, response.body
    end

    def test_no_gpg_key_content
      @repository.gpg_key = nil
      @repository.save
      get :gpg_key_content, :id => @repository.id

      assert_response 404
    end
  end
end
