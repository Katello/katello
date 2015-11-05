require "katello_test_helper"

module Katello
  class Api::V2::ContentViewHistoriesControllerTest < ActionController::TestCase
    def models
      @library_dev_staging_view = ContentView.find(katello_content_views(:library_dev_staging_view))
    end

    def permissions
      @view_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_index
      get :index, :content_view_id => @library_dev_staging_view

      assert_response :success
      assert_template 'katello/api/v2/content_view_histories/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, :destroy_content_views]

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :content_view_id => @library_dev_staging_view.id
      end
    end
  end
end
