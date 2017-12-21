require "katello_test_helper"

module Katello
  class Api::V2::FileUnitsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @file = FileUnit.find(katello_files(:one).id)
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products

      @auth_permissions = [@read_permission]
      @unauth_permissions = [@create_permission, @update_permission, @destroy_permission, @sync_permission]
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_index
      get :index

      assert_response :success
      assert_template "katello/api/v2/file_units/index"
    end

    def test_index_with_repo_id
      get :index, params: { :repository_id => @repo.id }

      assert_response :success
      assert_template "katello/api/v2/file_units/index"
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index
      end
    end

    def test_show
      get :show, params: { :id => @file.id }

      assert_response :success
      assert_template "katello/api/v2/file_units/show"
    end

    def test_show_protected
      assert_protected_action(:show, @auth_permissions, @unauth_permissions) do
        get :show, params: { :id => @file.id }
      end
    end

    def test_compare
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id] }
      assert_response :success
      assert_template "katello/api/v2/file_units/compare"

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id], :repository_id => @lib_repo.id }
      assert_response :success
      assert_template "katello/api/v2/file_units/compare"
    end
  end
end
