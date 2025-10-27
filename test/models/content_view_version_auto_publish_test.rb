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

      # Stub to return no scheduled, no running composite, no sibling tasks
      ForemanTasks::Task::DynflowTask.stubs(:for_action)
        .returns(stub(where: stub(any?: false)))  # Scheduled check: no scheduled tasks
        .then.returns(stub(where: stub(select: [])))  # Running composite check: none
        .then.returns(stub(where: stub(select: [])))  # Sibling check: none

      ForemanTasks.expects(:async_task).with(
        ::Actions::Katello::ContentView::Publish,
        @composite_cv,
        anything,
        triggered_by_id: @component1_version.id
      ).returns(stub(id: SecureRandom.uuid))

      @component1_version.auto_publish_composites!(task_id)
    end

    def test_auto_publish_with_sibling_tasks_uses_chaining
      task_id1 = SecureRandom.uuid
      task_id2 = SecureRandom.uuid

      sibling_task = stub(external_id: task_id2, input: { 'content_view' => { 'id' => @component_cv2.id } })

      ForemanTasks::Task::DynflowTask.stubs(:for_action)
        .returns(stub(where: stub(any?: false)))  # Scheduled check: no scheduled tasks
        .then.returns(stub(where: stub(select: [])))  # Running composite check: none
        .then.returns(stub(where: stub(select: [sibling_task])))  # Sibling check: found sibling

      ForemanTasks.expects(:chain).with(
        [task_id2],
        ::Actions::Katello::ContentView::Publish,
        @composite_cv,
        anything,
        triggered_by_id: @component1_version.id
      ).returns(stub(id: SecureRandom.uuid))

      @component1_version.auto_publish_composites!(task_id1)
    end

    def test_auto_publish_skips_when_composite_already_scheduled
      task_id = SecureRandom.uuid
      composite_task_id = SecureRandom.uuid

      # Create mock scheduled composite publish task with delayed plan args
      composite_task = stub(external_id: composite_task_id)
      delayed_plan = stub(args: [@composite_cv, "description", {}])

      # Mock the delayed plan lookup - need to allow the real dynflow world through
      # but intercept the persistence.load_delayed_plan call
      world_stub = ForemanTasks.dynflow.world
      persistence_stub = stub(load_delayed_plan: delayed_plan)
      world_stub.stubs(:persistence).returns(persistence_stub)

      # Stub scheduled check to return the composite task
      scheduled_relation = mock
      scheduled_relation.expects(:any?).yields(composite_task).returns(true)

      ForemanTasks::Task::DynflowTask.stubs(:for_action)
        .returns(stub(where: scheduled_relation))

      # Should not create any new task
      ForemanTasks.expects(:chain).never
      ForemanTasks.expects(:async_task).never

      @component1_version.auto_publish_composites!(task_id)
    end

    def test_auto_publish_schedules_event_when_composite_running
      task_id = SecureRandom.uuid
      running_task = stub(external_id: SecureRandom.uuid, input: { 'content_view' => { 'id' => @composite_cv.id } })

      ForemanTasks::Task::DynflowTask.stubs(:for_action)
        .returns(stub(where: stub(any?: false)))  # Scheduled check: none
        .then.returns(stub(where: stub(select: [running_task])))  # Running check: found running task

      # Should schedule event instead of creating task
      event_attrs = {}
      ::Katello::EventQueue.expects(:push_event).with(
        ::Katello::Events::AutoPublishCompositeView::EVENT_TYPE,
        @composite_cv.id
      ).yields(event_attrs)

      ForemanTasks.expects(:chain).never
      ForemanTasks.expects(:async_task).never

      @component1_version.auto_publish_composites!(task_id)
    end

    def test_auto_publish_handles_lock_conflict_gracefully
      task_id = SecureRandom.uuid

      ForemanTasks::Task::DynflowTask.stubs(:for_action)
        .returns(stub(where: stub(any?: false)))  # Scheduled check: none
        .then.returns(stub(where: stub(select: [])))  # Running composite check: none
        .then.returns(stub(where: stub(select: [])))  # Sibling check: none

      lock = stub('required_lock')
      conflicting_task = stub(id: 123)
      conflicting_lock = stub(task: conflicting_task)

      ForemanTasks.expects(:async_task).raises(ForemanTasks::Lock::LockConflict.new(lock, [conflicting_lock]))
      ::Katello::UINotifications::ContentView::AutoPublishFailure.expects(:deliver!).with(@composite_cv)

      assert_nothing_raised do
        @component1_version.auto_publish_composites!(task_id)
      end
    end

    def test_find_sibling_component_publish_tasks_finds_running_tasks
      task_id1 = SecureRandom.uuid
      task_id2 = SecureRandom.uuid

      # Create mock running tasks
      task1 = stub(external_id: task_id1, input: { 'content_view' => { 'id' => @component_cv1.id } })
      task2 = stub(external_id: task_id2, input: { 'content_view' => { 'id' => @component_cv2.id } })

      ForemanTasks::Task::DynflowTask.stubs(:for_action).returns(stub(where: stub(select: [task1, task2])))

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
      other_task = stub(external_id: SecureRandom.uuid, input: { 'content_view' => { 'id' => other_cv.id } })

      # The select block will filter out other_task
      ForemanTasks::Task::DynflowTask.stubs(:for_action).returns(stub(where: stub(select: [])))

      result = @component1_version.send(:find_sibling_component_publish_tasks, @composite_cv, task_id)

      # Should exclude current task and other CV's task
      assert_equal [], result
    end
  end
end
