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

    def test_index
      results = JSON.parse(get(:index).body)

      assert_response :success
      assert_template 'api/v2/host_collections/index'

      assert_equal results.keys.sort, ['error', 'page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 3
      assert_includes results['results'].map { |r| r['id'] }, @host_collection.id
    end

    def test_index_with_organization
      results = JSON.parse(get(:index, params: { :organization_id => @organization.id }).body)

      assert_response :success
      assert_template 'api/v2/host_collections/index'

      assert_equal results.keys.sort, ['error', 'page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 3
      assert_includes results['results'].map { |r| r['id'] }, @host_collection.id
    end

    def test_show
      results = JSON.parse(get(:show, params: { :id => @host_collection.id }).body)

      assert_equal results['name'], 'Simple Host Collection'

      assert_response :success
      assert_template 'api/v2/host_collections/show'
    end

    def test_create
      post :create, params: { :organization_id => @organization, :host_collection => {:name => 'Collection A', :description => 'Collection A, World Cup 2014'} }

      assert_response :success

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Collection A'
      assert_equal results['unlimited_hosts'], true
      assert_equal results['organization_id'], @organization.id
      assert_equal results['description'], 'Collection A, World Cup 2014'

      assert_template 'api/v2/host_collections/show'
    end

    def test_validate_hosts
      max_hosts = 1
      host_name = 'Collection A'
      post :create, params: { :organization_id => @organization, :name => host_name, :description => 'Collection A, World Cup 2014', :max_hosts => max_hosts, :unlimited_hosts => false, :host_ids => [@host.id, @host_two.id] }

      results = JSON.parse(response.body)

      error_message = "You cannot have more than #{max_hosts} host(s) associated with host collection #{host_name}."

      assert_response 422
      assert results["errors"]["base"].include?(error_message)
    end

    def test_max_host_validator_success
      put :update, params: { :id => @host_collection.id, :organization_id => @organization.id, :max_hosts => 2, :unlimited_hosts => false, :host_ids => [@host.id, @host_two.id] }

      assert_response :success
    end

    def test_max_host_validator_error
      put :update, params: { :id => @host_collection.id, :organization_id => @organization.id, :max_hosts => 1, :unlimited_hosts => false, :host_ids => [@host.id, @host_two.id] }

      results = JSON.parse(response.body)
      error_message = "may not be less than the number of hosts associated with the host collection."

      assert_response 422
      assert results["errors"]["max_host"].include?(error_message)
    end

    def test_max_host_zero
      put :update, params: { :id => @host_collection.id, :organization_id => @organization.id, :max_hosts => 0, :unlimited_hosts => false }

      results = JSON.parse(response.body)
      error_message = "must be a positive integer value."

      assert_response 422
      assert results["displayMessage"].include?(error_message)
    end

    def test_nil_max_hosts
      put :update, params: { :id => @host_collection.id, :organization_id => @organization.id, :unlimited_hosts => false }

      results = JSON.parse(response.body)
      error_message = "must be given a value if this host collection is not unlimited."

      assert_response 422
      assert results["displayMessage"].include?(error_message)
    end

    def test_create_with_host_id
      post :create, params: { :organization_id => @organization.id, :name => 'Collection A', :description => 'Collection A, World Cup 2014', :host_ids => [@host.id], :unlimited_hosts => true }

      results = JSON.parse(response.body)
      assert_equal results['total_hosts'], 1

      assert_response :success
      assert_template 'api/v2/host_collections/show'
    end

    def test_add_hosts_success
      success_message = "Successfully added 2 Host(s)."

      put :add_hosts, params: { id: @host_collection.id, host_ids: [298_486_374, 692_292_738] }

      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['success'], success_message
      assert results['displayMessages']['success'].one?, 'Expected only one success message'
      assert results['displayMessages']['error'].none?, 'Expected no error messages'

      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
    end

    def test_add_hosts_existing
      error_message = "Host with ID 980190962 already exists in the host collection."

      put :add_hosts, params: { id: @host_collection.id, host_ids: [980_190_962] }

      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['error'], error_message
      assert results['displayMessages']['error'].one?, 'Expected only one error message'
      assert results['displayMessages']['success'].none?, 'Expected no success messages'

      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
    end

    def test_add_hosts_unfound
      error_message = "Host with ID 827 not found."

      put :add_hosts, params: { id: @host_collection.id, host_ids: [827] }

      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['error'], error_message
      assert results['displayMessages']['error'].one?, 'Expected only one error message'
      assert results['displayMessages']['success'].none?, 'Expected no success messages'

      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
    end

    def test_remove_hosts_success
      success_message = "Successfully removed 1 Host(s)."

      put :remove_hosts, params: { id: @host_collection.id, host_ids: [980_190_962] }

      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['success'], success_message
      assert results['displayMessages']['success'].one?, 'Expected only one success message'
      assert results['displayMessages']['error'].none?, 'Expected no error messages'

      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
    end

    def test_remove_hosts_existing
      error_message = "Host with ID 298486374 does not exist in the host collection."

      put :remove_hosts, params: { id: @host_collection.id, host_ids: [298_486_374] }

      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['error'], error_message
      assert results['displayMessages']['error'].one?, 'Expected only one error message'
      assert results['displayMessages']['success'].none?, 'Expected no success messages'

      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
    end

    def test_remove_hosts_unfound
      error_message = "Host with ID 827 not found."

      put :remove_hosts, params: { id: @host_collection.id, host_ids: [827] }

      results = JSON.parse(response.body)
      assert_includes results['displayMessages']['error'], error_message
      assert results['displayMessages']['error'].one?, 'Expected only one error message'
      assert results['displayMessages']['success'].none?, 'Expected no success messages'

      assert_response :success
      assert_template 'katello/api/v2/common/bulk_action'
    end
  end
end
