require "katello_test_helper"

module Katello
  class Api::V2::PackageGroupsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)
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
      assert_template "katello/api/v2/package_groups/index"
    end

    def test_index_with_repo_id
      get :index, params: { :repository_id => @repo.id }

      assert_response :success
      assert_template "katello/api/v2/package_groups/index"
    end

    def test_index_with_content_view_version
      get :index, params: { :content_view_version_id => ContentViewVersion.first.id }

      assert_response :success
      assert_template "katello/api/v2/package_groups/index"
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first

      get :index, params: { :environment_id => environment.id }

      assert_response :success
      assert_template "katello/api/v2/package_groups/index"
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index
      end
    end

    def test_index_available_for_content_view_filter
      filtered_id = @package_group_filter.package_group_rules.first["uuid"]

      get :index, params: { :filterId => @package_group_filter, :available_for => "content_view_filter" }
      body = JSON.parse(response.body)
      response_ids = body["results"].map { |item| item["package_group_id"] }

      assert_response :success
      refute_includes response_ids, filtered_id
      assert response_ids.length > 0
    end

    def test_index_with_content_view_filter_id
      get :index, params: { content_view_filter_id: @package_group_filter }
      body = JSON.parse(response.body, symbolize_names: true)
      response_uuids = body[:results].map { |result| result[:uuid] }
      package_group_uuids = @package_group_filter.package_group_rules.map(&:uuid)

      assert_response :success
      assert body[:results].length > 0
      assert_equal response_uuids, package_group_uuids
    end

    def test_index_show_all_for_cv_filter
      get :index, params: { filterId: @package_group_filter.id, show_all_for: 'content_view_filter' }
      assert_response :success
      results = JSON.parse(response.body, symbolize_names: true)[:results]
      response_uuids = results.map { |rule| rule[:uuid] }
      package_group_uuids = @package_group_filter.package_group_rules.map(&:uuid)

      # All filtered pkg groups are in but also contains the available pkg groups
      assert package_group_uuids.all? { |uuid| response_uuids.include?(uuid) }
      assert response_uuids.length > package_group_uuids.length
    end

    def test_index_mutual_exclusive_params_error
      get :index, params: { filterId: @package_group_filter.id, show_all_for: 'content_view_filter', available_for: 'content_view_filter' }

      assert_response :unprocessable_entity
    end

    def test_show
      Pulp::PackageGroup.any_instance.stubs(:backend_data).returns({})
      NilClass.any_instance.stubs(:pulp3_repository_type_support?).returns(false)
      get :show, params: { :id => @repo.package_groups.first.id }

      assert_response :success
      assert_template "katello/api/v2/package_groups/show"
    end

    def test_show_by_uuid
      Pulp::PackageGroup.any_instance.stubs(:backend_data).returns({})
      NilClass.any_instance.stubs(:pulp3_repository_type_support?).returns(false)
      get :show, params: { :id => @repo.package_groups.first.pulp_id }

      assert_response :success
    end

    def test_show_group_not_found
      get :show, params: { :id => "3805853f-5cae-4a4a-8549-0ec86410f58f" }
      assert_response 404
    end

    def test_show_protected
      Pulp::PackageGroup.any_instance.stubs(:backend_data).returns({})

      assert_protected_action(:show, @auth_permissions, @unauth_permissions) do
        get :show, params: { :id => @repo.package_groups.first.id }
      end
    end

    def test_compare
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id] }
      assert_response :success
      assert_template "katello/api/v2/package_groups/compare"

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id], :repository_id => @lib_repo.id }
      assert_response :success
      assert_template "katello/api/v2/package_groups/compare"
    end

    def test_create_and_delete
      parameters = { :repository_id => @repo.id, :name => 'My_Group', :description => "My Group", :mandatory_package_names => ["katello-agent"]}
      assert_sync_task(::Actions::Katello::Repository::UploadPackageGroup) do |repository, params|
        repository.must_equal @repo
        params[:name].must_equal parameters[:name]
        params[:description].must_equal parameters[:description]
        params[:mandatory_package_names].must_equal parameters[:mandatory_package_names]
        params[:user_visible].must_equal true
      end

      post(:create, params: parameters)
      assert_response :success

      assert_sync_task(::Actions::Katello::Repository::DestroyPackageGroup) do |repository, pkg_group_id|
        repository.must_equal @repo
        pkg_group_id.must_equal "My_Group"
      end
      delete(:destroy, params: { :name => "My_Group", :repository_id => @repo.id })
      assert_response :success
    end
  end
end
