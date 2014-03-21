# encoding: utf-8
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
class Api::V2::SubscriptionsControllerTest < ActionController::TestCase

  include Support::ForemanTasks::Task

  def self.before_suite
    models = ["System"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    super
  end

  def models
    @system = katello_systems(:simple_server)
    @products = katello_products
    @organization = get_organization
  end

  def permissions
    @read_permission = UserPermission.new(:read, :organizations, @organization.id)
    @create_permission = UserPermission.new(:register_systems, :organizations, nil, @system.organization)
    @update_permission = UserPermission.new(:update_systems, :organizations, nil, @system.organization)
    @edit_permission = UserPermission.new(:update, :organizations)
    @no_permission = NO_PERMISSION
  end

  def setup
    setup_controller_defaults_api
    login_user(User.find(users(:admin)))
    @request.env['HTTP_ACCEPT'] = 'application/json'
    System.any_instance.stubs(:subscribe).returns(true)
    System.any_instance.stubs(:unsubscribe).returns(true)
    System.any_instance.stubs(:unsubscribe_all).returns(true)
    System.any_instance.stubs(:filtered_pools).returns([])
    System.any_instance.stubs(:releaseVer).returns(1)
    System.any_instance.stubs(:consumed_entitlements).returns([])
    @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)

    models
    permissions
  end

  def test_system_index
    get :index, :system_id => @system.uuid

    assert_response :success
    assert_template 'api/v2/subscriptions/index'
  end

  def test_index
    Provider.any_instance.stubs(:index_subscriptions).returns(true)
    get :index, :organization_id => @organization.label

    assert_response :success
    assert_template 'api/v2/subscriptions/index'
  end

  def test_index_protected
    allowed_perms = [@read_permission]
    denied_perms = [@no_permission]

    assert_protected_action(:index, allowed_perms, denied_perms) do
      get :index, :organization_id => @organization.label
    end
  end

  def test_available
    System.any_instance.expects(:filtered_pools)
    get :available, :system_id => @system.uuid

    assert_response :success
    assert_template 'api/v2/subscriptions/index'
  end

  def test_create
    System.any_instance.expects(:subscribe)
    post :create, :system_id => @system.uuid, :subscription => {
        :subscriptions => [:subscription => {:id => 'redhat', :quantity => 1}]}

    assert_response :success
    assert_template 'katello/api/v2/subscriptions/index'
  end

  def test_destroy
    System.any_instance.expects(:unsubscribe)
    delete :destroy, :system_id => @system.uuid, :subscription => {
        :subscriptions => [:subscription => {:id => 1}]}

    assert_response :success
    assert_template 'katello/api/v2/subscriptions/index'
  end

  def test_destroy_all
    System.any_instance.expects(:unsubscribe_all)
    delete :destroy, :system_id => @system.uuid

    assert_response :success
    assert_template 'katello/api/v2/subscriptions/index'
  end

  def test_blank_upload
    post :upload, :organization_id => @organization.label
    assert_response 400
  end

  def test_upload
    assert_async_task ::Actions::Katello::Provider::ManifestImport do |provider, path, force|
      assert_equal(@organization.redhat_provider.id, provider.id)
      assert_match(/\.zip$/, path)
    end
    test_document = File.join(Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
    manifest = Rack::Test::UploadedFile.new(test_document, '')
    post :upload, :organization_id => @organization.label, :content => manifest
    assert_response :success
  end

  def test_upload_protected
    allowed_perms = [@edit_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:upload, allowed_perms, denied_perms) do
      post :upload, :organization_id => @organization.label
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
    put :refresh_manifest, :organization_id => @organization.label
    assert_response :success
  end

  def test_refresh_protected
    allowed_perms = [@edit_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:refresh_manifest, allowed_perms, denied_perms) do
      put :refresh_manifest, :organization_id => @organization.label
    end
  end

  def test_delete_manifest
    Provider.any_instance.stubs(:delete_manifest)
    assert_async_task(::Actions::Katello::Provider::ManifestDelete) do |provider|
      assert_equal(@organization.redhat_provider.id, provider.id)
    end
    post :delete_manifest, :organization_id => @organization.label
    assert_response :success
  end

  def test_delete_protected
    allowed_perms = [@edit_permission]
    denied_perms = [@read_permission, @no_permission]

    assert_protected_action(:delete_manifest, allowed_perms, denied_perms) do
      post :delete_manifest, :organization_id => @organization.label
    end
  end
end
end
