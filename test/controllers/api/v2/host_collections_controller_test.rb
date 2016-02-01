# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostCollectionsControllerTest < ActionController::TestCase
    def models
      @host = FactoryGirl.create(:host)
      @host_two = hosts(:two)
      @host_collection = katello_host_collections(:simple_host_collection)
      @organization = get_organization

      HostCollection.stubs('any_readable?').with(@organization).returns(true)
      stub_find_organization(@organization)
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      models
    end

    def test_index
      results = JSON.parse(get(:index, :organization_id => @organization.id).body)

      assert_response :success
      assert_template 'api/v2/host_collections/index'

      assert_equal results.keys.sort, ['page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 3
      assert_includes results['results'].map { |r| r['id'] }, @host_collection.id
    end

    def test_show
      results = JSON.parse(get(:show, :id => @host_collection.id).body)

      assert_equal results['name'], 'Simple Host Collection'

      assert_response :success
      assert_template 'api/v2/host_collections/show'
    end

    def test_create
      post :create, :organization_id => @organization,
                    :host_collection => {:name => 'Collection A', :description => 'Collection A, World Cup 2014'}

      assert_response :success

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Collection A'
      assert_equal results['unlimited_hosts'], true
      assert_equal results['organization_id'], @organization.id
      assert_equal results['description'], 'Collection A, World Cup 2014'

      assert_template 'api/v2/host_collections/create'
    end

    def test_validate_hosts
      max_hosts = 1
      host_name = 'Collection A'
      post :create, :organization_id => @organization, :name => host_name, :description => 'Collection A, World Cup 2014',
           :max_hosts => max_hosts, :unlimited_hosts => false,
           :host_ids => [@host.id, @host_two.id]

      results = JSON.parse(response.body)

      error_message = "You cannot have more than #{max_hosts} host(s) associated with host collection #{host_name}."

      assert_response 422
      assert results["errors"]["base"].include?(error_message)
    end

    def test_max_host_validator
      put :update, :id => @host_collection.id, :organization_id => @organization.id,
                   :max_hosts => 2, :unlimited_hosts => false, :host_ids => [@host.id, @host_two.id]

      assert_response :success

      put :update, :id => @host_collection.id, :organization_id => @organization.id,
                   :max_hosts => 1

      results = JSON.parse(response.body)
      error_message = "may not be less than the number of hosts associated with the host collection."

      assert_response 422
      assert results["errors"]["max_host"].include?(error_message)
    end

    def test_max_host_zero
      put :update, :id => @host_collection.id, :organization_id => @organization.id,
                   :max_hosts => 0, :unlimited_hosts => false

      results = JSON.parse(response.body)
      error_message = "must be a positive integer value."

      assert_response 422
      assert results["displayMessage"].include?(error_message)
    end

    def test_nil_max_hosts
      put :update, :id => @host_collection.id, :organization_id => @organization.id,
                   :unlimited_hosts => false

      results = JSON.parse(response.body)
      error_message = "must be given a value if this host collection is not unlimited."

      assert_response 422
      assert results["displayMessage"].include?(error_message)
    end

    def test_create_with_host_id
      post :create, :organization_id => @organization.id, :name => 'Collection A',
           :description => 'Collection A, World Cup 2014', :host_ids => [@host.id], :unlimited_hosts => true

      results = JSON.parse(response.body)
      assert_equal results['total_hosts'], 1

      assert_response :success
      assert_template 'api/v2/host_collections/create'
    end
  end
end
