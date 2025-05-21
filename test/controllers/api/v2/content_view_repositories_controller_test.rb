require "katello_test_helper"

module Katello
  class Api::V2::ContentViewRepositoriesControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults_api
      @organization = get_organization
      @view = katello_content_views(:library_view)
      @fedora_repo = katello_repositories(:fedora_17_x86_64)
      @fedora_dup_repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @read_permission = :view_content_views
      @create_permission = :create_content_views
      @update_permission = :edit_content_views
      @destroy_permission = :destroy_content_views
    end

    def test_show_all
      get :show_all, params: { content_view_id: @view.id }

      assert_response :success
      results = JSON.parse(response.body, symbolize_names: true)[:results]
      added_ids = results.select { |r| r[:added_to_content_view] }.pluck(:id)
      not_added_ids = results.reject { |r| r[:added_to_content_view] }.pluck(:id)

      assert results.first[:added_to_content_view] # added to content view repos should show first
      assert_includes added_ids, @fedora_repo.id
      assert_includes not_added_ids, @fedora_dup_repo.id
    end

    def test_show_all_search
      get :show_all, params: { content_view_id: @view.id, search: "name = \"#{@fedora_repo.name}\"" }

      assert_response :success
      body = JSON.parse(response.body, symbolize_names: true)
      results = body[:results]

      assert_equal body[:subtotal].to_i, 2 # two repos have the same name
      assert_equal results.length, 2
      assert results.first[:added_to_content_view]
      refute results.last[:added_to_content_view]
      assert_includes results.pluck(:id), @fedora_repo.id
    end

    def test_show_all_with_content_type
      get :show_all, params: { content_view_id: @view.id, content_type: "docker" }

      assert_response :success
      body = JSON.parse(response.body, symbolize_names: true)
      results = body[:results]

      results.each { |result| assert_equal result[:content_type], "docker" }

      refute results.last[:added_to_content_view]
    end

    def test_show_all_protected
      allowed_perms = [@read_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show_all, allowed_perms, denied_perms) do
        get :show_all, params: { content_view_id: @view.id }
      end
    end

    def test_show_all_rolling
      @view = katello_content_views(:rolling_view)
      @container_push_repo = katello_repositories(:container_push)
      get :show_all, params: { content_view_id: @view.id }

      assert_response :success
      results = JSON.parse(response.body, symbolize_names: true)[:results]
      added_ids = results.select { |r| r[:added_to_content_view] }.pluck(:id)
      not_added_ids = results.reject { |r| r[:added_to_content_view] }.pluck(:id)

      assert_includes added_ids, @fedora_repo.id
      assert_not_includes added_ids, @container_push_repo.id
      assert_not_includes not_added_ids, @container_push_repo.id
    end
  end
end
