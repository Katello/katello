require 'katello_test_helper'

module Katello
  class ContentViewManagerTest < ActiveSupport::TestCase
    test 'request_auto_publish' do
      request = build_stubbed(:katello_content_view_auto_publish_request)
      cv = request.content_view
      cvv = request.content_view_version

      cv.expects(:create_auto_publish_request!).with(
        content_view_version: cvv
      ).returns(request)

      result = Katello::ContentViewManager.request_auto_publish(content_view: cv, content_view_version: cvv)

      assert_equal request, result
    end

    test 'request_auto_publish_exists' do
      cvv = build_stubbed(:katello_content_view_version)
      cv = cvv.content_view
      cv.expects(:create_auto_publish_request!).raises(ActiveRecord::RecordNotUnique)

      result = Katello::ContentViewManager.request_auto_publish(content_view: cv, content_view_version: cvv)

      assert_nil result
    end

    test 'trigger_auto_publish!' do
      request = build_stubbed(:katello_content_view_auto_publish_request)

      request.expects(:with_lock).yields
      request.expects(:destroy!)
      Katello::ContentViewManager.expects(:scheduled_composite_publish?).returns(false)
      Katello::ContentViewManager.expects(:running_component_publish_task_ids).returns([])
      ForemanTasks.expects(:async_task).with(
        ::Actions::Katello::ContentView::Publish,
        request.content_view,
        anything,
        auto_published: true,
        triggered_by_id: request.content_view_version_id
      )

      Katello::ContentViewManager.trigger_auto_publish!(request: request)
    end

    test 'trigger_auto_publish with chaining' do
      request = build_stubbed(:katello_content_view_auto_publish_request)
      sibling_task_ids = ['task-1', 'task-2']
      mock_world = mock('world')

      request.expects(:with_lock).yields
      request.expects(:destroy!)
      Katello::ContentViewManager.expects(:scheduled_composite_publish?).returns(false)
      Katello::ContentViewManager.expects(:running_component_publish_task_ids).returns(sibling_task_ids)
      ForemanTasks.dynflow.expects(:world).returns(mock_world)
      mock_world.expects(:chain).with(
        sibling_task_ids,
        Actions::Katello::ContentView::Publish,
        request.content_view,
        anything,
        auto_published: true,
        triggered_by_id: request.content_view_version_id
      )

      Katello::ContentViewManager.trigger_auto_publish!(request: request)
    end

    test 'trigger_auto_publish skips when composite already scheduled' do
      request = build_stubbed(:katello_content_view_auto_publish_request)

      request.expects(:with_lock).yields
      request.expects(:destroy!)
      Katello::ContentViewManager.expects(:scheduled_composite_publish?).returns(true)
      ForemanTasks.expects(:async_task).never

      Katello::ContentViewManager.trigger_auto_publish!(request: request)
    end

    test 'trigger_auto_publish locks found' do
      request = build_stubbed(:katello_content_view_auto_publish_request)

      request.expects(:with_lock).yields
      request.expects(:destroy!).never
      Katello::ContentViewManager.expects(:scheduled_composite_publish?).returns(false)
      Katello::ContentViewManager.expects(:content_view_locks).with(content_view: request.content_view).returns([1])
      ForemanTasks.expects(:async_task).never

      Katello::ContentViewManager.trigger_auto_publish!(request: request)
    end

    test 'trigger_auto_publish lock conflict' do
      request = build_stubbed(:katello_content_view_auto_publish_request)

      request.expects(:with_lock).yields
      request.expects(:destroy!).never
      Katello::ContentViewManager.expects(:scheduled_composite_publish?).returns(false)
      Katello::ContentViewManager.expects(:running_component_publish_task_ids).returns([])
      ForemanTasks.expects(:async_task).raises(ForemanTasks::Lock::LockConflict.new(mock, []))

      Katello::ContentViewManager.trigger_auto_publish!(request: request)
    end

    test 'trigger_auto_publish unhandled error' do
      request = build_stubbed(:katello_content_view_auto_publish_request)

      request.expects(:with_lock).yields
      Katello::ContentViewManager.expects(:scheduled_composite_publish?).returns(false)
      Katello::ContentViewManager.expects(:running_component_publish_task_ids).returns([])
      ForemanTasks.expects(:async_task).raises(StandardError)

      assert_raises(StandardError) do
        Katello::ContentViewManager.trigger_auto_publish!(request: request)
      end
    end
  end
end
