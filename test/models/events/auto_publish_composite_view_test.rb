require 'katello_test_helper'

module Katello
  module Events
    class AutoPublishCompositeViewTest < ActiveSupport::TestCase
      let(:composite_view) { katello_content_views(:composite_view) }

      def test_run_with_publish
        ForemanTasks.expects(:async_task)

        event = AutoPublishCompositeView.new(composite_view.id) do |instance|
          instance.metadata = {}
        end

        event.run
      end

      def test_run_with_error
        instance = AutoPublishCompositeView.new(composite_view.id)

        assert_raises(StandardError) { instance.run }
        refute instance.retry
      end

      def test_run_with_lock_error
        ForemanTasks.expects(:async_task).raises(ForemanTasks::Lock::LockConflict.new(mock, []))

        instance = AutoPublishCompositeView.new(composite_view.id) do |event|
          event.metadata = {}
        end

        assert_raises(ForemanTasks::Lock::LockConflict) { instance.run }
        assert instance.retry
      end
    end
  end
end
