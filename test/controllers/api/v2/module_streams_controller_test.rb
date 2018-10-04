require "katello_test_helper"

module Katello
  class Api::V2::ModuleStreamsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    def models
      @repo = katello_repositories(:fedora_17_x86_64)
      @module_stream_river = katello_module_streams(:river)
    end

    def setup
      setup_controller_defaults_api
      models
      setup_product_permissions
    end

    def test_index
      get :index

      assert_response :success
      assert_template "katello/api/v2/module_streams/index"
    end

    def test_index_with_repo_id
      get :index, params: { :repository_id => @repo.id }

      assert_response :success
      assert_template "katello/api/v2/module_streams/index"
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first

      get :index, params: { :environment_id => environment.id }

      assert_response :success
      assert_template "katello/api/v2/module_streams/index"
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index, params: { :repository_id => @repo.id }
      end
    end

    def test_index_with_name_stream_only
      get :index, params: { :name_stream_only => 1, :repository_id => @repo.id }

      assert_response :success
      assert_template "katello/api/v2/module_streams/name_streams"
    end

    def test_index_with_host_ids
      get :index, params: { :host_ids => [hosts(:one).id, hosts(:two).id], :repository_id => @repo.id }

      assert_response :success
      assert_template "katello/api/v2/module_streams/index"
    end

    def test_show
      get :show, params: { :id => @module_stream_river.id }

      assert_response :success
      assert_template "katello/api/v2/module_streams/show"
    end

    def test_show_by_uuid
      get :show, params: { :id => @module_stream_river.uuid }

      assert_response :success
      assert_template "katello/api/v2/module_streams/show"
    end

    def test_show_bad_id
      get :show, params: { :id => "Thisisafakeid" }

      assert_response 404
    end

    def test_show_protected
      assert_protected_action(:show, @auth_permissions, @unauth_permissions) do
        get :show, params: { :id => @module_stream_river.id }
      end
    end
  end
end
