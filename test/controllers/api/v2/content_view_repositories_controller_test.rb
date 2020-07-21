require "katello_test_helper"

module Katello
  class Api::V2::ContentViewRepositoriesControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults_api
      @view = katello_content_views(:library_view)
      @fedora_repo = katello_repositories(:fedora_17_x86_64)
      @fedora_dup_repo = katello_repositories(:fedora_17_x86_64_duplicate)
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

    def test_show_only_added
      get :show_all, params: { content_view_id: @view.id, only: "added" }

      assert_response :success
      body = JSON.parse(response.body, symbolize_names: true)
      results = body[:results]

      assert_equal body[:subtotal].to_i, 1
      assert_equal results.length, 1
      assert results.first[:added_to_content_view]
      assert_equal results.first[:id], @fedora_repo.id
    end

    def test_show_only_available
      get :show_all, params: { content_view_id: @view.id, only: "available" }

      assert_response :success
      body = JSON.parse(response.body, symbolize_names: true)
      results = body[:results]

      assert body[:subtotal].to_i > 1
      assert results.length > 1
      results.each { |result| refute result[:added_to_content_view], "#{result} returned the wrong value!" }
      assert_includes results.pluck(:id), @fedora_dup_repo.id
    end
  end
end
