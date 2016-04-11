# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::SystemsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @system = katello_systems(:simple_server)
      @errata_system = katello_systems(:errata_server)
      @organization = get_organization
      @repo = Repository.find(katello_repositories(:rhel_6_x86_64))
      @content_view_environment = ContentViewEnvironment.find(katello_content_view_environments(:library_dev_view_library))
      @host = ::Host::Managed.new
      @host.name = "testhost"
      @host.managed = false
      @host.content_host = @system
      @host.save!
      @pool_one = katello_pools(:pool_one)
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
      System.any_instance.stubs(:entitlements).returns([])
      System.any_instance.stubs(:products).returns([])

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

    def test_index_with_system_id_only
      get :index, :environment_id => @system.environment.id

      assert_response :success
      assert_template 'api/v2/systems/index'
    end

    def test_index_with_org_id_only
      get :index, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/systems/index'
    end

    def test_index_with_system_id_and_org_id
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

    def test_update
      host = @system.foreman_host
      input = {
        :id => @system.id,
        :release_ver => '7Server',
        :content_view_id => @system.content_view_id
      }
      where_stub = System.where(:id => @system.id)
      System.stubs(:where).returns(where_stub)
      System.any_instance.stubs(:first).returns(@system)
      @system.stubs(:foreman_host).returns(host)
      @controller.expects(:system_params).returns(input)

      subscription_facet = {:release_version => '7Server'}
      content_facet = {:content_view_id => @system.content_view_id}
      ::Host::Managed.any_instance.stubs(:update_attributes!).once.with(:subscription_facet_attributes => subscription_facet,
                                                                         :content_facet_attributes => content_facet)

      post :update, input
      assert_response :success
    end

    def test_search_by_name
      systems = System.search_for("name = \"#{@system.name}\"")
      assert_includes systems, @system
    end

    def test_search_by_content_view
      systems = System.search_for("content_view = \"#{@system.content_view.name}\"")
      assert_includes systems, @system
    end

    def test_search_by_activation_key
      systems = System.search_for("activation_key = \"#{@system.activation_keys.first.name}\"")
      assert_includes systems, @system
    end

    def test_search_by_host
      systems = System.search_for("host = \"#{@system.foreman_host}\"")
      assert_includes systems, @system
    end

    def test_search_by_environment
      systems = System.search_for("environment = \"#{@system.environment.name}\"")
      assert_includes systems, @system
    end
  end
end
