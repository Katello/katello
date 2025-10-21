require "katello_test_helper"

module Katello
  class Api::V2::AnsibleCollectionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    def models
      @repo = katello_repositories(:pulp3_ansible_collection_1)
      @collection_unit = katello_ansible_collections(:collection_one)
    end

    def setup
      setup_controller_defaults_api
      models
      setup_product_permissions
    end

    def test_index
      get :index

      assert_response :success
      assert_template "katello/api/v2/ansible_collections/index"
    end

    def test_index_with_repo_id
      get :index, params: { :repository_id => @repo.id }

      assert_response :success
      assert_template "katello/api/v2/ansible_collections/index"
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first

      get :index, params: { :environment_id => environment.id }

      assert_response :success
      assert_template "katello/api/v2/ansible_collections/index"
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions, [@repo.organization]) do
        get :index, params: { :repository_id => @repo.id }
      end
    end

    def test_show
      get :show, params: { :id => @collection_unit.id }

      assert_response :success
      assert_template "katello/api/v2/ansible_collections/show"
    end

    def test_show_bad_id
      get :show, params: { :id => "Thisisafakeid" }

      assert_response 404
    end

    def test_show_protected
      assert_protected_action(:show, @auth_permissions, @unauth_permissions, [@repo.organization]) do
        get :show, params: { :id => @collection_unit.id }
      end
    end
  end
end
