require "katello_test_helper"

module Katello
  class Api::V2::ErrataControllerTest < ActionController::TestCase
    def models
      ::Katello::Product.any_instance.stubs(:as_json).returns([])
      @test_repo = Repository.find(katello_repositories(:rhel_6_x86_64).id)
      @errata_filter = katello_content_view_filters(:populated_erratum_filter)
      @content_view_version = ContentViewVersion.first
      @host = FactoryBot.create(:host)
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

      Katello::Erratum.any_instance.stubs(:hosts_applicable).returns([])
      Katello::Erratum.any_instance.stubs(:hosts_available).returns([])

      models
      permissions
    end

    def test_index
      get :index, params: { :repository_id => @test_repo.id }
      assert_response :success
      assert_template "katello/api/v2/errata/index"

      get :index
      assert_response :success
      assert_template "katello/api/v2/errata/index"

      get :index, params: { :organization_id => @test_repo.organization.id }
      assert_response :success
      assert_template "katello/api/v2/errata/index"
    end

    def test_index_with_content_view_version
      get :index, params: { :content_view_version_id => @content_view_version.id }

      assert_response :success
      assert_template "katello/api/v2/errata/index"
    end

    def test_index_with_host_id
      get :index, params: { :host_id => @host.id }

      assert_response :success
      assert_template "katello/api/v2/errata/index"
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first

      get :index, params: { :environment_id => environment.id }

      assert_response :success
      assert_template "katello/api/v2/errata/index"
    end

    def test_index_with_filters
      get :index, params: { :content_view_filter_id => @errata_filter }

      package_group_filter = ContentViewFilter.find(katello_content_view_filters(:populated_package_group_filter).id)
      get :index, params: { :content_view_filter_id => package_group_filter }
    end

    def test_index_with_available_for_content_view_version
      get :index, params: { :content_view_version_id => @content_view_version.id, :available_for => 'content_view_version' }
      ids = JSON.parse(response.body)['results'].map { |item| item['errata_id'] }

      assert_response :success
      assert_template "katello/api/v2/errata/index"
      assert ids.length > 0
    end

    def test_index_with_available_for_content_view_filter
      filtered_id = @errata_filter.erratum_rules.first["errata_id"]

      get :index, params: { :filterId => @errata_filter, :available_for => "content_view_filter" }
      body = JSON.parse(response.body)
      response_ids = body["results"].map { |item| item["errata_id"] }

      assert_response :success
      refute_includes response_ids, filtered_id
      assert response_ids.length > 0
    end

    def test_index_with_available_for_content_view_filter_with_updated
      filtered_id = @errata_filter.erratum_rules.first["errata_id"]

      get :index, params: { :filterId => @errata_filter, :available_for => "content_view_filter", :date_type => "updated" }
      body = JSON.parse(response.body)
      response_ids = body["results"].map { |item| item["errata_id"] }

      assert_response :success
      refute_includes response_ids, filtered_id
      assert response_ids.length > 0
    end

    def test_index_with_cve
      cve = katello_erratum_cves(:cve)

      get :index, params: { :cve => cve.cve_id }

      assert_response :success
      assert_template "katello/api/v2/errata/index"
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index, params: { :repository_id => @test_repo.id }
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
        get :index, params: { :content_view_version_id => @content_view_version.id, :available_for => 'content_view_version' }
      end
    end

    def test_index_with_org_search
      test_repo2 = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      test_repo2.environment = katello_environments(:organization1_library)
      get :index, params: { :organization_id => test_repo2.organization.id }

      assert_response :success
      assert_equal JSON.parse(response.body)['results'].map { |item| item['errata_id'] }, []

      get :index, params: { :organization_id => @test_repo.organization.id }

      assert_response :success
      assert_equal JSON.parse(response.body)['results'].map { |item| item['errata_id'] }, ["RHSA-1999-1231", "RHBA-2014-013", "RHEA-2022-007"]
    end

    def test_show
      errata = @test_repo.errata.first

      get :show, params: { :repository_id => @test_repo.id, :id => errata.errata_id }

      assert_response :success
      assert_template "katello/api/v2/errata/show"
    end

    def test_show_errata_not_found
      get :show, params: { :repository_id => @test_repo.id, :id => "not a real errata id" }

      assert_response 404
    end

    def test_compare
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id] }
      assert_response :success
      assert_template "katello/api/v2/errata/compare"

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id], :repository_id => @lib_repo.id }
      assert_response :success
      assert_template "katello/api/v2/errata/compare"
    end

    def test_show_protected
      errata = @test_repo.errata.first
      Erratum.stubs(:find).with(errata.errata_id).returns(errata)

      assert_protected_action(:show, @auth_permissions, @unauth_permissions) do
        get :show, params: { :repository_id => @test_repo.id, :id => errata.errata_id }
      end
    end
  end
end
