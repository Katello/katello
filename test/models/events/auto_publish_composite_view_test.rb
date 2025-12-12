require 'katello_test_helper'

module Katello
  module Events
    class AutoPublishCompositeViewTest < ActiveSupport::TestCase
      let(:composite_view) { katello_content_views(:composite_view) }
      let(:component_version) { katello_content_view_versions(:library_view_version_1) }

      def test_run_with_publish
        calling_task_id = SecureRandom.uuid
        metadata = { description: "Auto Publish - Test", version_id: component_version.id, calling_task_id: calling_task_id }

        ::Katello::ContentViewVersion.expects(:trigger_composite_publish_with_coordination).with(
          composite_view,
          metadata[:description],
          metadata[:version_id],
          calling_task_id: calling_task_id
        )

        event = AutoPublishCompositeView.new(composite_view.id) do |instance|
          instance.metadata = metadata
        end

        event.run
      end

      def test_run_with_error
        instance = AutoPublishCompositeView.new(composite_view.id)

        assert_raises(StandardError) { instance.run }
        refute instance.retry
      end

      def test_run_with_lock_error
        calling_task_id = SecureRandom.uuid
        metadata = { description: "Auto Publish - Test", version_id: component_version.id, calling_task_id: calling_task_id }

        ::Katello::ContentViewVersion.expects(:trigger_composite_publish_with_coordination).raises(
          ForemanTasks::Lock::LockConflict.new(mock, [])
        )

        instance = AutoPublishCompositeView.new(composite_view.id) do |event|
          event.metadata = metadata
        end

        assert_raises(ForemanTasks::Lock::LockConflict) { instance.run }
        assert instance.retry
      end
    end
  end
end
