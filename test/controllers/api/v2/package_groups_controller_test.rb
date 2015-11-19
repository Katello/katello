require "katello_test_helper"

module Katello
  class Api::V2::PackageGroupsControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64))
      @package_group_filter = katello_content_view_filters(:populated_package_group_filter)
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
      assert_template %w(katello/api/v2/package_groups/index)
    end

    def test_index_with_repo_id
      get :index, :repository_id => @repo.id

      assert_response :success
      assert_template %w(katello/api/v2/package_groups/index)
    end

    def test_index_with_content_view_version
      get :index, :content_view_version_id => ContentViewVersion.first.id

      assert_response :success
      assert_template %w(katello/api/v2/package_groups/index)
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first
      KTEnvironment.expects(:readable).returns(stub(:find_by_id => environment))

      get :index, :environment_id => environment.id

      assert_response :success
      assert_template %w(katello/api/v2/package_groups/index)
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index
      end
    end

    def test_index_available_for_content_view_filter
      filtered_id = @package_group_filter.package_group_rules.first["uuid"]

      get :index, :filterId => @package_group_filter, :available_for => "content_view_filter"
      body = JSON.parse(response.body)
      response_ids = body["results"].map { |item| item["package_group_id"] }

      assert_response :success
      assert !(response_ids.include? filtered_id)
      assert response_ids.length > 0
    end

    def test_show
      Pulp::PackageGroup.any_instance.stubs(:backend_data).returns({})
      get :show, :id => @repo.package_groups.first.id

      assert_response :success
      assert_template %w(katello/api/v2/package_groups/show)
    end

    def test_show_by_uuid
      Pulp::PackageGroup.any_instance.stubs(:backend_data).returns({})
      get :show, :id => @repo.package_groups.first.uuid

      assert_response :success
    end

    def test_show_group_not_found
      get :show, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"
      assert_response 404
    end

    def test_show_protected
      Pulp::PackageGroup.any_instance.stubs(:backend_data).returns({})

      assert_protected_action(:show, @auth_permissions, @unauth_permissions) do
        get :show, :id => @repo.package_groups.first.id
      end
    end
  end
end
