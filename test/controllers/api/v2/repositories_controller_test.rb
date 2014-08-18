#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


require "katello_test_helper"

module Katello
class Api::V2::RepositoriesControllerTest < ActionController::TestCase

  include Support::ForemanTasks::Task

  def self.before_suite
    models = ["Repository", "Product"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    super
  end

  def models
    @organization = get_organization
    @repository = Repository.find(katello_repositories(:fedora_17_unpublished))
    @redhat_repository = katello_repositories(:rhel_6_x86_64)
    @product = katello_products(:fedora)
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
    @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
    models
    permissions
  end

  def test_index
    get :index, :organization_id => @organization.id

    assert_response :success
    assert_template 'api/v2/repositories/index'
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
      nil,
      nil
    ])

    product.expect(:editable?, @product.editable?)
    product.expect(:gpg_key, nil)
    product.expect(:organization, @organization)
    product.expect(:redhat?, false)
    assert_sync_task(::Actions::Katello::Repository::Create, @repository)

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
      nil,
      nil
    ])

    product.expect(:editable?, @product.editable?)
    product.expect(:gpg_key, nil)
    product.expect(:organization, @organization)
    product.expect(:redhat?, false)
    assert_sync_task(::Actions::Katello::Repository::Create, @repository)

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
      nil,
      key
    ])
    product.expect(:organization, @organization)
    product.expect(:redhat?, false)
    assert_sync_task(::Actions::Katello::Repository::Create, @repository)

    Product.stub(:find, product) do
      post :create, :name => 'Fedora Repository',
                    :product_id => @product.id,
                    :url => 'http://www.google.com',
                    :content_type => 'yum'

      assert_response :success
      assert_template 'api/v2/repositories/show'
    end
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
      attributes.must_equal({ 'gpg_key_id' => "#{key.id}", 'url' => nil })
    end
    put :update, :id => @repository.id, :repository => {:gpg_key_id => key.id}
    assert_response :success
    assert_template 'api/v2/repositories/show'
  end

  def test_update_empty_string_url
    assert_sync_task(::Actions::Katello::Repository::Update) do |repo, attributes|
      repo.must_equal @repository
      attributes.must_equal({ 'url' => nil })
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

  def test_remove_packages
    uuids = ['foo', 'bar']
    @controller.expects(:sync_task).with(::Actions::Katello::Repository::RemovePackages,
                                         @repository, uuids).once.returns(::ForemanTasks::Task.new)

    put :remove_packages, :id => @repository.id, :uuids => uuids
    assert_response :success
  end

  def test_remove_packages_protected
    allowed_perms = [@update_permission]
    denied_perms = [@read_permission, @create_permission, @destroy_permission]

    assert_protected_action(:remove_packages, allowed_perms, denied_perms) do
      put :remove_packages, :id => @repository.id, :uuids =>  ['foo', 'bar']
    end
  end

  def test_destroy
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
    Katello.config[:post_sync_url] = "http://foo.com/foo?token=#{token}"
    TaskStatus.stubs(:find_by_uuid).returns(TaskStatus.new(:user => User.first))
    Repository.stubs(:where).returns([@repository])

    post :sync_complete, :token => token, :payload => {:repo_id => @repository.pulp_id}, :call_report => {}

    assert_response :success
  end

  def test_sync_complete_bad_token
    token = 'super_secret'
    Katello.config[:post_sync_url] = "http://foo.com/foo?token=attacker_key"
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
    Repository.any_instance.stubs(:upload_content)

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
    Repository.any_instance.expects(:import_upload).with([1]).reutrns(true)
    Repository.any_instance.expects(:trigger_contents_changed).returns([])
    Repository.any_instance.expects(:unit_type_id).returns("rpm")

    put :import_uploads, :id => @repository.id, :upload_ids => [1]

    assert_response :success
  end

  def test_import_uploads
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
