require "katello_test_helper"

module Katello
  class Api::V2::PackagesControllerTest < ActionController::TestCase
    def models
      @repo = katello_repositories(:fedora_17_x86_64_dev)
      @version = ContentViewVersion.first
      @rpm = katello_rpms(:one)
      @rpm2 = katello_rpms(:two)
      @rpm3 = katello_rpms(:one_two)
      @host = hosts(:one)
      @simple_filter = katello_content_view_filters(:simple_filter)
      @one_package_rule = katello_content_view_package_filter_rules(:one_package_rule)
      @org = get_organization
      Pulp3::Rpm.any_instance.stubs(:backend_data).returns({ 'files' => [] })
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      models
      setup_product_permissions
    end

    def test_index
      get :index, params: { :repository_id => @repo.id, :organization_id => @org.id }

      assert_response :success
      assert_template "katello/api/v2/packages/index"

      get :index, params: { :content_view_version_id => @version.id, :organization_id => @org.id }

      assert_response :success
      assert_template "katello/api/v2/packages/index"
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first
      KTEnvironment.expects(:readable).returns(stub(:find_by => environment))

      get :index, params: { :environment_id => environment.id }

      assert_response :success
      assert_template "katello/api/v2/packages/index"
    end

    def test_thindex
      response = get :thindex

      assert_response :success
      assert_template "katello/api/v2/packages/thindex"

      response_data = JSON.parse(response.body)
      results = response_data['results'] || []
      assert_includes results.map { |rpm| rpm['id'] }, @rpm.id
      refute_includes results.map { |rpm| rpm['id'] }, @rpm3.id
    end

    def test_index_not_distinct_by_name
      response = get :index

      assert_response :success
      assert_template "katello/api/v2/packages/index"

      response_data = JSON.parse(response.body)
      results = response_data['results'] || []
      [@rpm, @rpm3].each do |rpm|
        assert_includes results.map { |result| result['id'] }, rpm.id
      end
    end

    def test_index_parameters
      get :index

      assert_response :success
    end

    def test_index_with_applicability
      response = get :index, params: { :host_id => @host.id, :organization_id => @org.id }

      assert_response :success

      ids = JSON.parse(response.body)['results'].map { |p| p['id'] }
      assert_includes ids, @rpm.id
    end

    def test_index_with_upgradability
      response = get :index, params: { :host_id => @host.id, :packages_restrict_upgradable => true,
                                       :organization_id => @org.id }

      assert_response :success
      ids = JSON.parse(response.body)['results'].map { |p| p['id'] }
      refute_includes ids, @rpm.id
    end

    def test_index_with_available_for_content_view_version
      response = get :index, params: { :content_view_version_id => @version.id, :available_for => 'content_view_version',
                                       :organization_id => @org.id }

      assert_response :success
      ids = JSON.parse(response.body)['results'].map { |p| p['id'] }
      assert_includes ids, @rpm.id
    end

    def test_index_with_latest
      response = get :index, params: { :packages_restrict_latest => true, :organization_id => @org.id }

      assert_response :success
      ids = JSON.parse(response.body)['results'].map { |p| p['id'] }
      assert_includes ids, katello_rpms(:one_two).id
      refute_includes ids, @rpm.id
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index, params: { :repository_id => @repo.id }
      end
    end

    def test_index_with_available_for_content_view_version_protected
      cv_auth_permissions = [:view_content_views]
      cv_unauth_permissions = [
        :create_content_views, :edit_content_views, :destroy_content_views, :publish_content_views,
        :promote_or_remove_content_views, :export_content
      ]
      all_unauth_permissions = @unauth_permissions + cv_unauth_permissions
      assert_protected_action(:index, cv_auth_permissions, all_unauth_permissions) do
        get :index, params: { :content_view_version_id => @version.id, :available_for => 'content_view_version' }
      end
    end

    def test_index_with_content_view_filter_id
      response = get :index, params: { content_view_filter_id: @simple_filter.id, :organization_id => @org.id }
      response_body = JSON.parse(response.body, symbolize_names: true)

      assert_response :success
      assert response_body[:results].length > 0
      assert_includes response_body[:results].pluck(:id), @rpm.id
    end

    def test_index_with_content_view_filter_rule_id
      response = get :index, params: { content_view_filter_rule_id: @one_package_rule.id, :organization_id => @org.id }
      response_body = JSON.parse(response.body, symbolize_names: true)

      assert_response :success
      assert response_body[:results].length > 0
      assert_includes response_body[:results].pluck(:id), @rpm.id
    end

    def test_autocomplete_name
      response = get :auto_complete_name, params: { :repoids => [@repo.id], :term => @rpm.name[0] }

      assert_response :success
      assert_includes JSON.parse(response.body), @rpm.name
    end

    def test_show
      get :show, params: { :id => @rpm.id }

      assert_response :success
      assert_template "katello/api/v2/packages/show"
    end

    def test_show_uuid
      get :show, params: { :id => @rpm.pulp_id }

      assert_response :success
      assert_template "katello/api/v2/packages/show"
    end

    def test_show_package_not_found
      get :show, params: { :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f" }
      assert_response 404
    end

    def test_show_protected
      assert_protected_action(:show, @auth_permissions, @unauth_permissions) do
        get :show, params: { :repository_id => @repo.id, :id => @rpm.pulp_id }
      end
    end

    def test_compare
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      @lib_repo.rpms = [katello_rpms(:one)]
      @view_repo.rpms = [katello_rpms(:two)]

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id] }
      assert_response :success
      assert_template "katello/api/v2/packages/compare"

      response = get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id], :repository_id => @lib_repo.id }
      assert_response :success
      assert_template "katello/api/v2/packages/compare"
      assert_equal 2, JSON.parse(response.body)['total']
    end

    def test_compare_same
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      @lib_repo.rpms = [katello_rpms(:one), katello_rpms(:two)]
      @view_repo.rpms = [katello_rpms(:two)]

      response = get :compare, params: { content_view_version_ids: [@lib_repo.content_view_version_id, @view_repo.content_view_version_id], restrict_comparison: 'same', repository_id: @lib_repo.id }
      assert_response :success
      assert_template "katello/api/v2/packages/compare"
      assert_equal 1, JSON.parse(response.body)['total']
    end

    def test_compare_different
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      cv1_packages = Katello::ContentViewVersion.find(@lib_repo.content_view_version_id).packages.pluck(:id)
      cv2_packages = Katello::ContentViewVersion.find(@view_repo.content_view_version_id).packages.pluck(:id)

      unique_package_ids = (cv1_packages + cv2_packages)
      same_package_ids = cv1_packages.intersection cv2_packages
      different_package_ids = unique_package_ids - same_package_ids

      response = get :compare, params: { content_view_version_ids: [@lib_repo.content_view_version_id, @view_repo.content_view_version_id], restrict_comparison: 'different' }
      assert_response :success
      assert_template "katello/api/v2/packages/compare"
      assert_equal different_package_ids&.count, JSON.parse(response.body)['total']
    end
  end
end
