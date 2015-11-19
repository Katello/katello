# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostCollectionsControllerTest < ActionController::TestCase
    def models
      @host = FactoryGirl.create(:host)

      @host_collection = katello_host_collections(:simple_host_collection)
      @organization = get_organization

      HostCollection.stubs('any_readable?').with(@organization).returns(true)
      stub_find_organization(@organization)
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)

      models
    end

    def test_index
      results = JSON.parse(get(:index, :organization_id => @organization.id).body)

      assert_response :success
      assert_template 'api/v2/host_collections/index'

      assert_equal results.keys.sort, ['page', 'per_page', 'results', 'search', 'sort', 'subtotal', 'total']
      assert_equal results['results'].size, 3
      assert_block do
        ids = []
        results['results'].each do |r|
          ids << r['id']
        end
        ids.include? @host_collection.id
      end
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

    def test_create_with_host_id
      post :create, :organization_id => @organization,
           :host_collection => {:name => 'Collection A', :description => 'Collection A, World Cup 2014',
                                :host_ids => [@host.id]}

      results = JSON.parse(response.body)
      assert_equal results['host_ids'], [@host.id]

      assert_response :success
      assert_template 'api/v2/host_collections/create'
    end
  end
end
