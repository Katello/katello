require "katello_test_helper"

module Actions
  module Helpers
    class ContentViewAutoPublisherTest < ActiveSupport::TestCase
      include Dynflow::Testing

      class AutoPublish < Actions::EntryAction
        include ContentViewAutoPublisher

        def plan(_resource, cvv_id = nil, cv_ids = nil)
          plan_self(cvv_id: cvv_id, cv_ids: cv_ids)
        end

        def run
          output[:auto_publish_content_view_version_id] = input[:cvv_id]
          output[:auto_publish_content_view_ids] = input[:cv_ids]
        end
      end

      let(:action) { create_action AutoPublish }

      it 'adds auto publish cv id to the input for content view' do
        cv = build_stubbed(:katello_content_view)

        plan_action action, cv

        assert_equal cv.id, action.input[:auto_publish_content_view_id]
      end

      it 'adds auto publish cv id to the input for content view version' do
        cvv = build_stubbed(:katello_content_view_version)

        plan_action action, cvv

        assert_equal cvv.content_view.id, action.input[:auto_publish_content_view_id]
      end

      it 'raises an error when auto publish cv not determined' do
        assert_raises(RuntimeError) do
          plan_action action, mock
        end
      end

      it 'auto publishes cv when stopped' do
        request = build_stubbed(:katello_content_view_auto_publish_request)
        cv = request.content_view

        ::Katello::ContentViewAutoPublishRequest.expects(:find_by).with(content_view_id: cv.id).returns(request)
        ::Katello::ContentViewManager.expects(:trigger_auto_publish!).with(request: request)

        ForemanTasks.sync_task(AutoPublish, cv)
      end

      it 'auto publishes cvs resiliently' do
        request = build_stubbed(:katello_content_view_auto_publish_request)
        cvv = request.content_view_version
        cv = request.content_view

        ::Katello::ContentViewVersion.expects(:find_by).returns cvv
        ::Katello::ContentView.expects(:auto_publishable).returns(mock(where: [cv]))
        ::Katello::ContentViewManager.expects(:request_auto_publish).returns(request)
        ::Katello::ContentViewManager.expects(:trigger_auto_publish!).raises(StandardError)
        ::Katello::UINotifications::ContentView::AutoPublishFailure.expects(:deliver!).with(cv)

        task = ForemanTasks.sync_task(AutoPublish, cv, cvv.id, [cv.id])

        assert_equal 'success', task.result
        assert_equal 'stopped', task.state
      end

      it 'auto publishes cvs on success' do
        request = build_stubbed(:katello_content_view_auto_publish_request)
        cvv = request.content_view_version
        cv = request.content_view

        ::Katello::ContentViewVersion.expects(:find_by).returns cvv
        ::Katello::ContentView.expects(:auto_publishable).returns(mock(where: [cv]))
        ::Katello::ContentViewManager.expects(:request_auto_publish).returns(request)
        ::Katello::ContentViewManager.expects(:trigger_auto_publish!)

        task = ForemanTasks.sync_task(AutoPublish, cv, cvv.id, [cv.id])

        assert_equal 'success', task.result
        assert_equal 'stopped', task.state
      end
    end
  end
end
