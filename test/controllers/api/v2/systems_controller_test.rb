# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::SystemsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @system = katello_systems(:simple_server)
      @errata_system = katello_systems(:errata_server)
      @host_collections = katello_host_collections
      @organization = get_organization
      @repo = Repository.find(katello_repositories(:rhel_6_x86_64))
      @content_view_environment = ContentViewEnvironment.find(katello_content_view_environments(:library_dev_view_library))
    end

    def permissions
      @view_permission = :view_content_hosts
      @create_permission = :create_content_hosts
      @update_permission = :edit_content_hosts
      @destroy_permission = :destroy_content_hosts
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'

      System.any_instance.stubs(:candlepin_consumer_info).returns(:facts => {})
      System.any_instance.stubs(:katello_agent_installed?).returns(true)
      System.any_instance.stubs(:refresh_subscriptions).returns(true)
      System.any_instance.stubs(:content_overrides).returns([])
      System.any_instance.stubs(:products).returns([])
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)

      Katello::PuppetModule.stubs(:module_count).returns(0)

      models
      permissions
    end

    def test_index
      get :index, :organization_id => get_organization.id

      assert_response :success
      assert_template 'api/v2/systems/index'
    end

    def test_index_errata
      errata = @repo.errata.first
      get :index, :organization_id => get_organization.id, :erratum_id => errata.uuid

      assert_response :success
      assert_template 'api/v2/systems/index'
    end

    def test_index_errata_applicable
      @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      errata = @repo.errata.first
      get :index, :organization_id => get_organization.id, :erratum_id => errata.uuid, :available => "false"

      assert_response :success
      assert_template 'api/v2/systems/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :organization_id => @organization.id
      end
    end

    def test_create
      @controller.stubs(:sync_task).returns(true)
      System.stubs(:new).returns(@system)
      cp_id = @content_view_environment.cp_id
      ContentViewEnvironment.expects(:find_by_cp_id!).with(cp_id).returns(@content_view_environment)
      post :create, :name => "needs more tests", :environment_id => cp_id.to_s,
        :organization_id => @organization.id
      assert_response :success
    end

    def test_create_without_environment
      @controller.stubs(:sync_task).returns(true)
      System.stubs(:new).returns(@system)
      post :create, :name => "needs more tests", :organization_id => @organization.id
      assert_response :success
    end

    def test_index_with_system_id_only
      mock = Api::V2::SystemsController.any_instance.expects(:item_search).with do |_model, _params, options|
        terms = options[:filters].inject({}) { |all_terms, filter| all_terms.merge(filter[:terms]) }
        terms[:environment_id] ==  @system.environment.id.to_s
      end
      mock.returns({})

      get :index, :environment_id => @system.environment.id

      assert_response :success
      assert_template 'api/v2/systems/index'
    end

    def test_index_with_org_id_only
      mock = Api::V2::SystemsController.any_instance.expects(:item_search).with do |_model, _params, options|
        terms = options[:filters].inject({}) { |all_terms, filter| all_terms.merge(filter[:terms]) }
        terms[:environment_id] == @organization.kt_environments.pluck(:id)
      end
      mock.returns({})

      get :index, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/systems/index'
    end

    def test_index_with_system_id_and_org_id
      mock = Api::V2::SystemsController.any_instance.expects(:item_search).with do |_model, _params, options|
        terms = options[:filters].inject({}) { |all_terms, filter| all_terms.merge(filter[:terms]) }
        terms[:environment_id] == [@system.environment.id]
      end
      mock.returns({})

      get :index, :organization_id => @organization.id, :environment_id => @system.environment.id

      assert_response :success
      assert_template 'api/v2/systems/index'
    end

    def test_show
      get :show, :id => @system.uuid

      assert_response :success
      assert_template 'api/v2/systems/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, :id => @system.uuid
      end
    end

    def test_refresh_subscriptions
      input = {
        :id => @system.id
      }
      System.stubs(:where).returns(@system)
      System.any_instance.stubs(:first).returns(@system)
      assert_sync_task(::Actions::Katello::System::AutoAttachSubscriptions) do |sys|
        sys.must_equal @system
      end
      put :refresh_subscriptions, input
      assert_response :success
      assert_template 'api/v2/systems/show'
    end

    def test_refresh_subscriptions_protected
      allowed_perms = [@update_permission]
      denied_perms = [@create_permission, @view_permission, @destroy_permission]

      assert_protected_action(:refresh_subscriptions, allowed_perms, denied_perms) do
        put :refresh_subscriptions, :id => @system.uuid
      end
    end

    def test_available_host_collections
      get :available_host_collections, :id => @system.uuid

      assert_response :success
      assert_template 'api/v2/systems/available_host_collections'
    end

    def test_available_host_collections_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:available_host_collections, allowed_perms, denied_perms) do
        get :available_host_collections, :id => @system.uuid
      end
    end

    def test_update
      input = {
        :id => @system.id,
        :name => 'newname'
      }
      System.stubs(:where).returns(@system)
      System.any_instance.stubs(:first).returns(@system)
      @controller.expects(:system_params).returns(input)
      assert_sync_task(::Actions::Katello::System::Update) do |sys, inp|
        sys.must_equal @system
        inp.must_equal input
      end
      post :update, input
      assert_response :success
    end

    def test_content_override_protected
      allowed_perms = [@update_permission]
      denied_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:content_override, allowed_perms, denied_perms) do
        put(:content_override, :id => @system.uuid, :content_label => 'some-content',
            :value => 1)
      end
    end

    def test_content_override
      System.any_instance.stubs(:available_content).returns([Candlepin::ProductContent.new(:content => {:label => 'some-content'})])
      Resources::Candlepin::Consumer.expects(:update_content_override).with(@system.uuid, 'some-content', 'enabled', 1)
      put :content_override, :id => @system.uuid, :content_override => {:content_label => 'some-content', :value => 1}

      assert_response :success
      assert_template 'api/v2/systems/content_override'
    end

    def test_invalid_content_fails
      System.any_instance.stubs(:available_content).returns([Candlepin::ProductContent.new(:content => {:label => 'some-content'})])
      put :content_override, :id => @system.uuid, :content_override => {:content_label => 'wrong-content', :value => 1}

      assert_response 400
    end

    def test_product_content_protected
      allowed_perms = [@view_permission]
      denied_perms = [@update_permission, @create_permission, @destroy_permission]

      assert_protected_action(:product_content, allowed_perms, denied_perms) do
        get(:product_content, :id => @system.uuid)
      end
    end

    def test_product_content
      get :product_content, :id => @system.uuid

      assert_response :success
      assert_template 'api/v2/systems/product_content'
    end
  end
end
