require 'katello_test_helper'

module Katello
  class ContentViewVersionAutoPublishTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @org = FactoryBot.create(:katello_organization)

      # Create two component content views
      @component_cv1 = FactoryBot.create(:katello_content_view, :organization => @org, :name => "Component CV 1")
      @component_cv2 = FactoryBot.create(:katello_content_view, :organization => @org, :name => "Component CV 2")

      # Create a composite content view with auto-publish enabled
      @composite_cv = FactoryBot.create(:katello_content_view,
                                         :organization => @org,
                                         :composite => true,
                                         :auto_publish => true,
                                         :name => "Composite CV")

      # Add components to composite
      @component1_version = FactoryBot.create(:katello_content_view_version,
                                               :content_view => @component_cv1,
                                               :major => 1,
                                               :minor => 0)
      @component2_version = FactoryBot.create(:katello_content_view_version,
                                               :content_view => @component_cv2,
                                               :major => 1,
                                               :minor => 0)

      # For latest: true, set content_view (not content_view_version)
      # Validation requires: either (latest=true + content_view) OR (content_view_version)
      FactoryBot.create(:katello_content_view_component,
                        :composite_content_view => @composite_cv,
                        :content_view => @component_cv1,
                        :latest => true)
      FactoryBot.create(:katello_content_view_component,
                        :composite_content_view => @composite_cv,
                        :content_view => @component_cv2,
                        :latest => true)
    end

    def test_auto_publish_with_no_sibling_tasks_triggers_immediately
      task_id = SecureRandom.uuid

      # Mock that no other tasks are running
      task_relation = mock('task_relation')
      task_relation.expects(:where).with(state: ['planning', 'planned', 'running']).returns(task_relation).twice
      task_relation.expects(:select).returns([]).twice # No component or composite tasks

      ForemanTasks::Task::DynflowTask.expects(:for_action)
        .with(::Actions::Katello::ContentView::Publish)
        .returns(task_relation)
        .twice # Once for component check, once for composite check

      # Should trigger async_task since no siblings are running
      ForemanTasks.expects(:async_task).with(
        ::Actions::Katello::ContentView::Publish,
        @composite_cv,
        anything,
        triggered_by_id: @component1_version.id
      ).returns(stub(id: SecureRandom.uuid))

      # Should not call chain
      ForemanTasks.expects(:chain).never

      @component1_version.auto_publish_composites!(task_id)
    end

    def test_auto_publish_with_sibling_tasks_uses_chaining
      task_id1 = SecureRandom.uuid
      task_id2 = SecureRandom.uuid

      # Create mock running task for sibling component
      sibling_task = mock('sibling_task')
      sibling_task.stubs(:external_id).returns(task_id2)
      sibling_task.stubs(:input).returns({
        'content_view' => { 'id' => @component_cv2.id }
      })

      # Mock that sibling task is running
      task_relation = mock('task_relation')
      task_relation.expects(:where).with(state: ['planning', 'planned', 'running']).returns(task_relation).twice
      task_relation.expects(:select).returns([sibling_task]).once # component check - sibling found
      task_relation.expects(:select).returns([]).once # composite check - no composite tasks

      ForemanTasks::Task::DynflowTask.expects(:for_action)
        .with(::Actions::Katello::ContentView::Publish)
        .returns(task_relation)
        .twice

      # Should use chain since sibling is running
      # Current task is excluded, only sibling remains
      # Order: composite_task_ids (empty) + sibling_task_ids ([sibling only, current excluded])
      ForemanTasks.expects(:chain).with(
        [task_id2], # only sibling task, current task excluded
        ::Actions::Katello::ContentView::Publish,
        @composite_cv,
        anything,
        triggered_by_id: @component1_version.id
      ).returns(stub(id: SecureRandom.uuid))

      # Should not call async_task
      ForemanTasks.expects(:async_task).never

      @component1_version.auto_publish_composites!(task_id1)
    end

    def test_auto_publish_waits_for_running_composite_publish
      task_id = SecureRandom.uuid
      composite_task_id = SecureRandom.uuid

      # Create mock running composite publish task
      composite_task = mock('composite_task')
      composite_task.stubs(:external_id).returns(composite_task_id)
      composite_task.stubs(:input).returns({
        'content_view' => { 'id' => @composite_cv.id }
      })

      # Mock that no component tasks are running, but composite is
      task_relation = mock('task_relation')
      task_relation.expects(:where).with(state: ['planning', 'planned', 'running']).returns(task_relation).twice
      task_relation.expects(:select).returns([]).once # No component tasks
      task_relation.expects(:select).returns([composite_task]).once # Composite task running

      ForemanTasks::Task::DynflowTask.expects(:for_action)
        .with(::Actions::Katello::ContentView::Publish)
        .returns(task_relation)
        .twice

      # Should use chain to wait for composite task to finish
      # Order: composite_task_ids + sibling_task_ids (empty, current excluded)
      ForemanTasks.expects(:chain).with(
        [composite_task_id], # only composite task
        ::Actions::Katello::ContentView::Publish,
        @composite_cv,
        anything,
        triggered_by_id: @component1_version.id
      ).returns(stub(id: SecureRandom.uuid))

      # Should not call async_task
      ForemanTasks.expects(:async_task).never

      @component1_version.auto_publish_composites!(task_id)
    end

    def test_auto_publish_handles_lock_conflict_gracefully
      task_id = SecureRandom.uuid

      # Mock that no other tasks are running
      task_relation = mock('task_relation')
      task_relation.expects(:where).with(state: ['planning', 'planned', 'running']).returns(task_relation).twice
      task_relation.expects(:select).returns([]).twice # No component or composite tasks

      ForemanTasks::Task::DynflowTask.expects(:for_action)
        .with(::Actions::Katello::ContentView::Publish)
        .returns(task_relation)
        .twice

      # Simulate lock conflict (composite already being published)
      # LockConflict needs 2 args: required_lock and conflicting_locks
      # The conflicting locks need to respond to .task for error message generation
      lock = mock('required_lock')
      conflicting_task = mock('conflicting_task')
      conflicting_task.stubs(:id).returns(123)
      conflicting_lock = mock('conflicting_lock')
      conflicting_lock.stubs(:task).returns(conflicting_task)

      ForemanTasks.expects(:async_task).raises(ForemanTasks::Lock::LockConflict.new(lock, [conflicting_lock]))

      # Should deliver failure notification but not raise
      ::Katello::UINotifications::ContentView::AutoPublishFailure.expects(:deliver!).with(@composite_cv)

      # Should not raise exception
      assert_nothing_raised do
        @component1_version.auto_publish_composites!(task_id)
      end
    end

    def test_find_sibling_component_publish_tasks_finds_running_tasks
      task_id1 = SecureRandom.uuid
      task_id2 = SecureRandom.uuid

      # Create mock running tasks
      task1 = mock('task1')
      task1.stubs(:external_id).returns(task_id1)
      task1.stubs(:input).returns({ 'content_view' => { 'id' => @component_cv1.id } })

      task2 = mock('task2')
      task2.stubs(:external_id).returns(task_id2)
      task2.stubs(:input).returns({ 'content_view' => { 'id' => @component_cv2.id } })

      task_relation = mock('task_relation')
      task_relation.expects(:select).returns([task1, task2])

      ForemanTasks::Task::DynflowTask.expects(:for_action)
        .with(::Actions::Katello::ContentView::Publish)
        .returns(task_relation)

      task_relation.expects(:where).with(state: ['planning', 'planned', 'running']).returns(task_relation)

      current_task_id = SecureRandom.uuid
      result = @component1_version.send(:find_sibling_component_publish_tasks, @composite_cv, current_task_id)

      # Should include both sibling tasks but exclude current task
      assert_equal 2, result.length
      assert_includes result, task_id1
      assert_includes result, task_id2
      assert_not_includes result, current_task_id
    end

    def test_find_sibling_tasks_excludes_non_component_tasks
      task_id = SecureRandom.uuid

      # Create mock task for a different CV (not a component)
      other_cv = FactoryBot.create(:katello_content_view, :organization => @org)
      other_task = mock('other_task')
      other_task.stubs(:external_id).returns(SecureRandom.uuid)
      other_task.stubs(:input).returns({ 'content_view' => { 'id' => other_cv.id } })

      task_relation = mock('task_relation')
      # The select block will filter out other_task because other_cv.id is not in component_cv_ids
      # So we return empty array
      task_relation.expects(:select).returns([])

      ForemanTasks::Task::DynflowTask.expects(:for_action)
        .with(::Actions::Katello::ContentView::Publish)
        .returns(task_relation)

      task_relation.expects(:where).with(state: ['planning', 'planned', 'running']).returns(task_relation)

      result = @component1_version.send(:find_sibling_component_publish_tasks, @composite_cv, task_id)

      # Should exclude current task and other CV's task
      assert_equal [], result
    end
  end
end
