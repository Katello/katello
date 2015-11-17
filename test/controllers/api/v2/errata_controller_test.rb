require "katello_test_helper"

module Katello
  class Api::V2::ErrataControllerTest < ActionController::TestCase
    def models
      ::Katello::Product.any_instance.stubs(:as_json).returns([])
      @test_repo = Repository.find(katello_repositories(:rhel_6_x86_64))
      @errata_filter = katello_content_view_filters(:populated_erratum_filter)
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

      Katello::Erratum.any_instance.stubs(:systems_applicable).returns([])
      Katello::Erratum.any_instance.stubs(:systems_available).returns([])

      models
      permissions
    end

    def test_index
      get :index, :repository_id => @test_repo.id
      assert_response :success
      assert_template %w(katello/api/v2/errata/index)

      get :index
      assert_response :success
      assert_template %w(katello/api/v2/errata/index)

      get :index, :organization_id => @test_repo.organization.id
      assert_response :success
      assert_template %w(katello/api/v2/errata/index)
    end

    def test_index_with_content_view_version
      @content_view_version = ContentViewVersion.first
      ContentViewVersion.expects(:readable).returns(stub(:find_by_id => @content_view_version))

      get :index, :content_view_version_id => @content_view_version.id

      assert_response :success
      assert_template %w(katello/api/v2/errata/index)
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first
      KTEnvironment.expects(:readable).returns(stub(:find_by_id => environment))

      get :index, :environment_id => environment.id

      assert_response :success
      assert_template %w(katello/api/v2/errata/index)
    end

    def test_index_with_filters
      get :index, :content_view_filter_id => @errata_filter

      package_group_filter = ContentViewFilter.find(katello_content_view_filters(:populated_package_group_filter))
      get :index, :content_view_filter_id => package_group_filter
    end

    def test_index_available_errata_for_content_view_filter
      filtered_id = @errata_filter.erratum_rules.first["errata_id"]

      get :index, :filterId => @errata_filter, :available_for => "content_view_filter"
      body = JSON.parse(response.body)
      response_ids = body["results"].map { |item| item["errata_id"] }

      assert_response :success
      assert !(response_ids.include? filtered_id)
      assert response_ids.length > 0
    end

    def test_index_with_cve
      cve = katello_erratum_cves(:cve)

      get :index, :cve => cve.cve_id
      assert_response :success
      assert_template %w(katello/api/v2/errata/index)
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index, :repository_id => @test_repo.id
      end
    end

    def test_show
      errata = @test_repo.errata.first
      get :show, :repository_id => @test_repo.id, :id => errata.errata_id

      assert_response :success
      assert_template %w(katello/api/v2/errata/show)
    end

    def test_show_errata_not_found
      get :show, :repository_id => @test_repo.id, :id => "not a real errata id"
      assert_response 404
    end

    def test_compare
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      get :compare, :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id]
      assert_response :success
      assert_template %w(katello/api/v2/errata/compare)

      get :compare, :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id],
                    :repository_id => @lib_repo.id
      assert_response :success
      assert_template %w(katello/api/v2/errata/compare)
    end

    def test_show_protected
      errata = @test_repo.errata.first
      Erratum.stubs(:find).with(errata.errata_id).returns(errata)

      assert_protected_action(:show, @auth_permissions, @unauth_permissions) do
        get :show, :repository_id => @test_repo.id, :id => errata.errata_id
      end
    end
  end
end
