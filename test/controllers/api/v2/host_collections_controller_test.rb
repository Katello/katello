# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostCollectionsControllerTest < ActionController::TestCase
    def models
      @host = FactoryBot.create(:host)
      @host_two = hosts(:two)
      @host_collection = katello_host_collections(:simple_host_collection)
      @organization = get_organization
      @host.update_attribute :organization_id, @organization.id
      @host_two.update_attribute :organization_id, @organization.id

      HostCollection.stubs('any_readable?').with(@organization).returns(true)
      stub_find_organization(@organization)
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      models
    end

    test_attributes :pid => '6ae32df2-b917-4830-8709-15fb272b76c1'
    def test_index
      get :index
      assert_response :success
      assert_template 'api/v2/host_collections/index'

      results = JSON.parse(@response.body)
      assert_equal results.keys.sort, ['error', 'page', 'per_page', 'results', 'search', 'selectable', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 4
      assert_includes results['results'].map { |r| r['id'] }, @host_collection.id
    end

    test_attributes :pid => '5f9de8ab-2c53-401b-add3-57d86c97563a'
    def test_index_with_organization
      get :index, params: { :organization_id => @organization.id }
      assert_response :success
      assert_template 'api/v2/host_collections/index'

      results = JSON.parse(@response.body)
      assert_equal results.keys.sort, ['error', 'page', 'per_page', 'results', 'search', 'selectable', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 4
      assert_includes results['results'].map { |r| r['id'] }, @host_collection.id
    end

    test_attributes :pid => '444a1528-64c8-41b6-ba2b-6c49799d5980'
    def test_show
      get :show, params: { :id => @host_collection.id }
      assert_response :success
      assert_template 'api/v2/host_collections/show'

      results = JSON.parse(@response.body)
      assert_equal results['name'], 'Simple Host Collection'
      assert results.key?('host_ids')
      assert_includes results['host_ids'], hosts(:one).id
    end

    def test_create
      post :create, params: { :organization_id => @organization, :host_collection => {:name => 'Collection A', :description => 'Collection A, World Cup 2014'} }

      assert_response 201
      assert_template 'api/v2/host_collections/create'

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Collection A'
      assert_equal results['unlimited_hosts'], true
      assert_equal results['organization_id'], @organization.id
      assert_equal results['description'], 'Collection A, World Cup 2014'
    end

    def test_validate_hosts
      max_hosts = 1
      host_name = 'Collection A'
      post :create, params: { :organization_id => @organization, :name => host_name, :description => 'Collection A, World Cup 2014', :max_hosts => max_hosts, :unlimited_hosts => false, :host_ids => [@host.id, @host_two.id] }
      assert_response :unprocessable_entity
      results = JSON.parse(response.body)
      error_message = "You cannot have more than #{max_hosts} host(s) associated with host collection #{host_name}."
      assert_includes results["errors"]["base"], error_message
    end

    def test_max_host_validator_success
      put :update, params: { :id => @host_collection.id, :organization_id => @organization.id, :max_hosts => 2, :unlimited_hosts => false, :host_ids => [@host.id, @host_two.id] }
      assert_response :success
    end

    def test_max_host_validator_error
      put :update, params: { :id => @host_collection.id, :organization_id => @organization.id, :max_hosts => 1, :unlimited_hosts => false, :host_ids => [@host.id, @host_two.id] }
      assert_response :unprocessable_entity
      results = JSON.parse(response.body)
      error_message = "may not be less than the number of hosts associated with the host collection."
      assert_includes results["errors"]["max_host"], error_message
    end

    def test_max_host_zero
      put :update, params: { :id => @host_collection.id, :organization_id => @organization.id, :max_hosts => 0, :unlimited_hosts => false }
      assert_response :unprocessable_entity
      results = JSON.parse(response.body)
      error_message = "must be a positive integer value."
      assert_includes results["displayMessage"], error_message
    end

    def test_nil_max_hosts
      put :update, params: { :id => @host_collection.id, :organization_id => @organization.id, :unlimited_hosts => false }
      assert_response :unprocessable_entity
      results = JSON.parse(response.body)
      error_message = "must be given a value if this host collection is not unlimited."
      assert_includes results["displayMessage"], error_message
    end

    test_attributes :pid => '9dc0ad72-58c2-4079-b1ca-2c4373472f0f'
    def test_create_with_host_id
      post :create, params: { :organization_id => @organization.id, :name => 'Collection A', :description => 'Collection A, World Cup 2014', :host_ids => [@host.id], :unlimited_hosts => true }
      assert_response :success
      assert_template 'api/v2/host_collections/create'
      results = JSON.parse(response.body)
      assert_equal results['total_hosts'], 1
    end

    def test_add_hosts_success
      success_message = "Successfully added 2 Host(s)."
      put :add_hosts, params: { id: @host_collection.id, host_ids: [298_486_374, 692_292_738] }
      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['success'], success_message
      assert results['displayMessages']['success'].one?, 'Expected only one success message'
      assert results['displayMessages']['error'].none?, 'Expected no error messages'
    end

    def test_add_hosts_existing
      error_message = "Host with ID 980190962 already exists in the host collection."
      put :add_hosts, params: { id: @host_collection.id, host_ids: [980_190_962] }
      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['error'], error_message
      assert results['displayMessages']['error'].one?, 'Expected only one error message'
      assert results['displayMessages']['success'].none?, 'Expected no success messages'
    end

    def test_add_hosts_unfound
      error_message = "Host with ID 827 not found."
      put :add_hosts, params: { id: @host_collection.id, host_ids: [827] }
      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['error'], error_message
      assert results['displayMessages']['error'].one?, 'Expected only one error message'
      assert results['displayMessages']['success'].none?, 'Expected no success messages'
    end

    def test_remove_hosts_success
      success_message = "Successfully removed 1 Host(s)."
      put :remove_hosts, params: { id: @host_collection.id, host_ids: [980_190_962] }
      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['success'], success_message
      assert results['displayMessages']['success'].one?, 'Expected only one success message'
      assert results['displayMessages']['error'].none?, 'Expected no error messages'
    end

    def test_remove_hosts_existing
      error_message = "Host with ID 298486374 does not exist in the host collection."
      put :remove_hosts, params: { id: @host_collection.id, host_ids: [298_486_374] }
      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['error'], error_message
      assert results['displayMessages']['error'].one?, 'Expected only one error message'
      assert results['displayMessages']['success'].none?, 'Expected no success messages'
    end

    def test_remove_hosts_unfound
      error_message = "Host with ID 827 not found."
      put :remove_hosts, params: { id: @host_collection.id, host_ids: [827] }
      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['error'], error_message
      assert results['displayMessages']['error'].one?, 'Expected only one error message'
      assert results['displayMessages']['success'].none?, 'Expected no success messages'
    end

    def test_unauthorized_update
      allowed_perms = [{:name => "edit_host_collections", :search => "name=\"#{@host_collection.name}\"" }]
      denied_perms = [{:name => "edit_host_collections", :search => "name=\"some_name\"" }]

      assert_protected_object(:put, allowed_perms, denied_perms) do
        put :update, params: { :id => @host_collection.id }
      end
    end

    test_attributes :pid => '13a16cd2-16ce-4966-8c03-5d821edf963b'
    def test_destroy
      delete :destroy, params: { :id => @host_collection.id }
      assert_response :success
      refute HostCollection.exists?(@host_collection.id)
    end
  end
end
