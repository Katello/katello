require 'katello_test_helper'

module Katello
  class ContentViewManagerTest < ActiveSupport::TestCase
    test 'auto_publish_composites!' do
      cvv = build_stubbed(:katello_content_view_version)
      composite = build_stubbed(:katello_content_view)

      cvv.content_view.expects(:publishable_composites).returns([composite])
      Katello::ContentViewManager.expects(:auto_publish!).once.with(
        content_view_version: cvv,
        content_view: composite
      )

      Katello::ContentViewManager.auto_publish_composites!(content_view_version: cvv)
    end

    test 'auto_publish_composites! request exists' do
      cvv = build_stubbed(:katello_content_view_version)
      composite = build_stubbed(:katello_content_view)

      cvv.content_view.expects(:publishable_composites).returns([composite])
      Katello::ContentViewManager.expects(:auto_publish!).raises(ActiveRecord::RecordNotUnique)

      Katello::ContentViewManager.auto_publish_composites!(content_view_version: cvv)
    end

    test 'auto_publish!' do
      request = build_stubbed(:katello_content_view_auto_publish_request)
      composite = build_stubbed(:katello_content_view)
      composite.expects(:create_auto_publish_request!).returns(request)
      cvv = build_stubbed(:katello_content_view_version)

      ForemanTasks.expects(:async_task).with(::Actions::Katello::ContentView::AutoPublish, request)

      Katello::ContentViewManager.auto_publish!(
        content_view: composite,
        content_view_version: cvv
      )
    end
  end
end
