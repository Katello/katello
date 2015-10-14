# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::HostCollectionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @system = katello_systems(:simple_server)
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
      System.any_instance.stubs(:update_host_collections)

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
                    :host_collection => {:name => 'Collection A', :description => 'Collection A, World Cup 2014',
                                         :system_ids => [@system.id]}

      assert_response :success

      results = JSON.parse(response.body)
      assert_equal results['name'], 'Collection A'
      assert_equal results['unlimited_content_hosts'], true
      assert_equal results['organization_id'], @organization.id
      assert_equal results['description'], 'Collection A, World Cup 2014'
      assert_equal results['system_ids'], [@system.id]

      assert_template 'api/v2/host_collections/create'
    end

    def test_create_with_system_uuid
      post :create, :organization_id => @organization, :system_uuids => [@system.uuid],
        :host_collection => {:name => 'Collection A', :description => 'Collection A, World Cup 2014'}

      results = JSON.parse(response.body)
      assert_equal results['system_ids'], [@system.id]

      assert_response :success
      assert_template 'api/v2/host_collections/create'
    end

    # Host collection w/o any content hosts
    def test_autoattach_subscriptions_empty
      put(:autoattach_subscriptions, :id => @host_collection.id)
      assert_response :error
    end

    def test_autoattach_subscriptions
      System.stubs(:find).returns([@system])
      assert_async_task ::Actions::BulkAction do |action_class, systems|
        action_class.must_equal ::Actions::Katello::System::BulkAutoAttachSubscriptions
        systems.must_equal [@system]
      end
      put(:autoattach_subscriptions, :id => @host_collection.id)
      assert_response :success
    end

    def test_subscriptions
      @controller.stubs(:respond_for_index)
      get(:subscriptions, :id => @host_collection.id)
    end

    def test_add_subscriptions
      System.stubs(:find).returns([@system])
      assert_async_task ::Actions::BulkAction do |action_class, systems|
        action_class.must_equal ::Actions::Katello::System::BulkAttachSubscriptions
        systems.must_equal [@system]
      end
      put(:add_subscriptions, :id => @host_collection.id)
      assert_response :success
    end

    def test_remove_subscriptions
      System.stubs(:find).returns([@system])
      assert_async_task ::Actions::BulkAction do |action_class, systems|
        action_class.must_equal ::Actions::Katello::System::BulkUnattachSubscriptions
        systems.must_equal [@system]
      end
      get(:remove_subscriptions, :id => @host_collection.id)
      assert_response :success
    end

    def test_available_subscriptions
      get(:available_subscriptions, :id => @host_collection.id)
      assert_response :success
    end
  end
end
