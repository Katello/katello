require "katello_test_helper"

module Katello
  class Api::V2::ContentExportsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
      @export_permission = :export_content_views
    end

    def setup
      setup_controller_defaults_api
      @library_dev_staging_view = ContentView.find(katello_content_views(:library_dev_staging_view).id)
      permissions
    end

    def test_export_api_status_true_for_pulp3
      FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      get :api_status
      assert_response :success
      assert JSON.parse(@response.body)["api_usable"]
    end

    def test_export_api_status_false_for_pulp2
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      get :api_status
      assert_response :success
      refute JSON.parse(@response.body)["api_usable"]
    end

    def test_index_protected
      allowed_perms = [@export_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, params: { :content_view_id => @library_dev_staging_view.id }
      end
    end

    def test_export_api_status_protected
      allowed_perms = [@export_permission, @view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:api_status, allowed_perms, denied_perms) do
        get :api_status
      end
    end

    def test_export_pulp3_assert_invalid_params
      SmartProxy.stubs(:pulp_primary).returns(FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3))

      version = @library_dev_staging_view.versions.first
      post :version, params: { :id => version.id, :iso_mb_size => 5, :export_to_iso => "foo"}
      assert_response :bad_request
    end

    def test_export_with_pulp2repo_fail
      SmartProxy.stubs(:pulp_primary).returns(FactoryBot.create(:smart_proxy, :default_smart_proxy))

      version = @library_dev_staging_view.versions.first
      post :version, params: { :id => version.id, :iso_mb_size => 5, :export_to_iso => "foo"}
      response = JSON.parse(@response.body)['displayMessage']
      assert_equal response, 'Invalid usage for Pulp 2 repositories. Use export for Yum repositories'
      assert_response :bad_request
    end

    def test_export_pulp3_missing_destination
      SmartProxy.stubs(:pulp_primary).returns(FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3))

      version = @library_dev_staging_view.versions.first
      post :version, params: { :id => version.id}
      assert_response :bad_request
    end

    def test_version_protected
      allowed_perms = [@export_permission]
      denied_perms = [@create_permission, @update_permission,
                      @destroy_permission, @view_permission]
      version = @library_dev_staging_view.versions.first

      assert_protected_action(:version, allowed_perms, denied_perms) do
        post :version, params: { :id => version.id }
      end
    end
  end
end
