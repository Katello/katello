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
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      User.current = User.find(users(:admin))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      models
      permissions
      [:package_group_count, :package_count, :puppet_module_count].each do |content_type_count|
        Repository.any_instance.stubs(content_type_count).returns(0)
      end
    end

    def test_index
      get :index, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/repositories/index'
    end

    def assert_response_ids(response, expected)
      body = JSON.parse(response.body)
      found_ids = body['results'].map { |item| item['id'] }
      refute_empty expected
      assert_equal expected.sort, found_ids.sort
    end

    def test_index_with_product_id
      ids = Repository.where(:product_id => @product.id, :library_instance_id => nil).pluck(:id)

      response = get :index, :product_id => @product.id, :organization_id => @organization.id
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

    def test_index_with_content_view_version_id
      ids = @view.versions.first.repositories.pluck(:id)

      response = get :index, :content_view_version_id => @view.versions.first.id, :organization_id => @organization.id

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
      product = MiniTest::Mock.new
      product.expect(:add_repo, @repository, [
        'Fedora_Repository',
        'Fedora Repository',
        'http://www.google.com',
        'yum',
        true,
        nil,
        nil
      ])

      product.expect(:editable?, @product.editable?)
      product.expect(:gpg_key, nil)
      product.expect(:organization, @organization)
      product.expect(:redhat?, false)
      product.expect(:unprotected?, true)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stub(:find, product) do
        post :create, :name => 'Fedora Repository',
                      :product_id => @product.id,
                      :url => 'http://www.google.com',
                      :content_type => 'yum'

        assert_response :success
        assert_template 'api/v2/repositories/show'
      end
    end

    def test_create_with_empty_string_url
      product = MiniTest::Mock.new
      product.expect(:add_repo, @repository, [
        'Fedora_Repository',
        'Fedora Repository',
        nil,
        'yum',
        true,
        nil,
        nil
      ])

      product.expect(:editable?, @product.editable?)
      product.expect(:gpg_key, nil)
      product.expect(:organization, @organization)
      product.expect(:redhat?, false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stub(:find, product) do
        post :create, :name => 'Fedora Repository',
                      :product_id => @product.id,
                      :url => '',
                      :content_type => 'yum'

        assert_response :success
        assert_template 'api/v2/repositories/show'
      end
    end

    def test_create_with_gpg_key
      key = GpgKey.find(katello_gpg_keys('fedora_gpg_key'))

      product = MiniTest::Mock.new
      product.expect(:gpg_key, key)
      product.expect(:editable?, @product.editable?)

      product.expect(:add_repo, @repository, [
        'Fedora_Repository',
        'Fedora Repository',
        'http://www.google.com',
        'yum',
        true,
        key,
        nil
      ])
      product.expect(:organization, @organization)
      product.expect(:redhat?, false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stub(:find, product) do
        post :create, :name => 'Fedora Repository',
                      :product_id => @product.id,
                      :url => 'http://www.google.com',
                      :content_type => 'yum'

        assert_response :success
        assert_template 'api/v2/repositories/show'
      end
    end

    def test_create_with_checksum
      product = MiniTest::Mock.new
      product.expect(:add_repo, @repository, [
        'Fedora_Repository',
        'Fedora Repository',
        nil,
        'yum',
        true,
        nil,
        'sha256'
      ])

      product.expect(:editable?, @product.editable?)
      product.expect(:gpg_key, nil)
      product.expect(:organization, @organization)
      product.expect(:redhat?, false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stub(:find, product) do
        post :create, :name => 'Fedora Repository',
                      :product_id => @product.id,
                      :url => '',
                      :content_type => 'yum',
                      :checksum_type => 'sha256'

        assert_response :success
        assert_template 'api/v2/repositories/show'
      end
    end

    def test_create_with_protected_true
      product = MiniTest::Mock.new
      product.expect(:add_repo, @repository, [
        'Fedora_Repository',
        'Fedora Repository',
        'http://www.google.com',
        'yum',
        false,
        nil,
        nil
      ])

      product.expect(:editable?, @product.editable?)
      product.expect(:gpg_key, nil)
      product.expect(:organization, @organization)
      product.expect(:redhat?, false)
      product.expect(:unprotected?, false)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stub(:find, product) do
        post :create, :name => 'Fedora Repository',
                      :product_id => @product.id,
                      :url => 'http://www.google.com',
                      :content_type => 'yum',
                      :unprotected => false

        assert_response :success
        assert_template 'api/v2/repositories/show'
      end
    end

    def test_create_with_protected_docker
      docker_upstream_name = "busybox"
      product = MiniTest::Mock.new
      product.expect(:add_repo, @repository, [
        'Fedora_Repository',
        'Fedora Repository',
        'http://hub.registry.com',
        'docker',
        true,
        nil,
        nil
      ])

      product.expect(:editable?, @product.editable?)
      product.expect(:gpg_key, nil)
      product.expect(:organization, @organization)
      product.expect(:redhat?, false)
      product.expect(:unprotected?, true)
      product.expect(:docker_upstream_name, docker_upstream_name)
      assert_sync_task(::Actions::Katello::Repository::Create, @repository, false, true)

      Product.stub(:find, product) do
        post :create, :name => 'Fedora Repository',
                      :product_id => @product.id,
                      :url => 'http://hub.registry.com',
                      :content_type => 'docker',
                      :docker_upstream_name => "busybox"

        assert_response :success
        assert_template 'api/v2/repositories/show'
      end
    end

    def test_create_without_label_or_name
      post :create, :product_id => @product.id
      assert_response 400
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
      key = GpgKey.find(katello_gpg_keys('fedora_gpg_key'))
      assert_sync_task(::Actions::Katello::Repository::Update) do |repo, attributes|
        repo.must_equal @repository
        attributes.must_equal('gpg_key_id' => "#{key.id}", 'url' => nil)
      end
      put :update, :id => @repository.id, :repository => {:gpg_key_id => key.id}
      assert_response :success
      assert_template 'api/v2/repositories/show'
    end

    def test_update_empty_string_url
      assert_sync_task(::Actions::Katello::Repository::Update) do |repo, attributes|
        repo.must_equal @repository
        attributes.must_equal('url' => nil)
      end
      put :update, :id => @repository.id, :repository => {:url => ''}

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

    def test_remove_content
      @repository.rpms << @rpm
      @controller.expects(:sync_task).with(::Actions::Katello::Repository::RemoveContent,
                                           @repository, [@rpm]).once.returns(::ForemanTasks::Task.new)

      put :remove_content, :id => @repository.id, :uuids => [@rpm.uuid]

      assert_response :success
    end

    def test_remove_content_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:remove_content, allowed_perms, denied_perms) do
        put :remove_content, :id => @repository.id, :uuids =>  ['foo', 'bar']
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
            files.size == 1 && files.first.include?("puppet_module.tar.gz")
      end

      post :upload_content, :id => @repository.id, :content => [puppet_module]
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
