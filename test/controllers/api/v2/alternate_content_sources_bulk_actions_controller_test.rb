require "katello_test_helper"

module Katello
  class Api::V2::AlternateContentSourcesBulkActionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      User.current = User.find(users(:admin).id)
      @acss = katello_alternate_content_sources(:yum_alternate_content_source, :file_alternate_content_source)
      @acss.first.save
      @acss.second.save
    end

    def test_destroy_alternate_content_sources
      assert_async_task(::Actions::BulkAction) do |action_class|
        assert_equal action_class, ::Actions::Katello::AlternateContentSource::Destroy
      end

      put :destroy_alternate_content_sources, params: { ids: @acss.collect(&:id) }

      assert_response :success
    end

    def test_refresh
      assert_async_task(::Actions::BulkAction) do |action_class, acss|
        assert_equal action_class, ::Actions::Katello::AlternateContentSource::Refresh
        assert_equal @acss.map(&:id).sort, acss.map(&:id).sort
      end

      post :refresh_alternate_content_sources, params: { ids: @acss.collect(&:id) }

      assert_response :success
    end
  end
end
