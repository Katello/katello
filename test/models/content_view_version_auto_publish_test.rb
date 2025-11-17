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

    def test_auto_publish_schedules_event_when_no_composite_activity
      task_id = SecureRandom.uuid

      # Stub to return no scheduled, no running composite
      ForemanTasks::Task::DynflowTask.stubs(:for_action)
        .returns(stub(where: stub(any?: false))) # Scheduled check: no scheduled tasks
        .then.returns(stub(where: stub(select: [])))  # Running composite check: none

      ::Katello::EventQueue.expects(:push_event).with(
        ::Katello::Events::AutoPublishCompositeView::EVENT_TYPE,
        @composite_cv.id
      )

      @component1_version.auto_publish_composites!(task_id)
    end

    def test_auto_publish_schedules_event_when_composite_running
      task_id = SecureRandom.uuid
      running_task = stub(external_id: SecureRandom.uuid, input: { 'content_view' => { 'id' => @composite_cv.id } })

      # Stub to return no scheduled but a running composite
      ForemanTasks::Task::DynflowTask.stubs(:for_action)
        .returns(stub(where: stub(any?: false))) # Scheduled check: no scheduled tasks
        .then.returns(stub(where: stub(select: [running_task]))) # Running composite check: found running

      ::Katello::EventQueue.expects(:push_event).with(
        ::Katello::Events::AutoPublishCompositeView::EVENT_TYPE,
        @composite_cv.id
      )

      @component1_version.auto_publish_composites!(task_id)
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

      # Should not schedule event when already scheduled
      ::Katello::EventQueue.expects(:push_event).never

      @component1_version.auto_publish_composites!(task_id)
    end

  end
end
