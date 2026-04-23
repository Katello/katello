require 'katello_test_helper'

module Katello
  class ErrataApplicationTest < ActiveSupport::TestCase
    def setup
      @host = hosts(:one)
      @erratum = katello_errata(:security)
      @user = User.first
    end

    def test_create_valid_application
      application = ErrataApplication.create(
        host: @host,
        errata_ids: [@erratum.id],
        applied_at: Time.zone.now,
        status: 'success',
        user: @user
      )

      assert application.valid?
      assert_equal @host.id, application.host_id
      assert_includes application.errata_ids, @erratum.id
      assert_equal 'success', application.status
    end

    def test_requires_host
      application = ErrataApplication.new(
        errata_ids: [@erratum.id],
        applied_at: Time.zone.now
      )

      refute application.valid?
      assert_includes application.errors[:host], "can't be blank"
    end

    def test_requires_errata_ids
      application = ErrataApplication.new(
        host: @host,
        applied_at: Time.zone.now
      )

      refute application.valid?
      assert_includes application.errors[:errata_ids], "can't be blank"
    end

    def test_requires_applied_at
      application = ErrataApplication.new(
        host: @host,
        errata_ids: [@erratum.id]
      )

      refute application.valid?
      assert_includes application.errors[:applied_at], "can't be blank"
    end

    def test_requires_status
      application = ErrataApplication.new(
        host: @host,
        errata_ids: [@erratum.id],
        applied_at: Time.zone.now,
        status: nil
      )

      refute application.valid?
      assert_includes application.errors[:status], "can't be blank"
    end

    def test_validates_status_inclusion
      application = ErrataApplication.new(
        host: @host,
        errata_ids: [@erratum.id],
        applied_at: Time.zone.now,
        status: 'invalid_status'
      )

      refute application.valid?
      assert_includes application.errors[:status], "is not included in the list"
    end

    def test_uniqueness_constraint_by_task
      task = create_task_with_errata(@host, [@erratum.errata_id])

      ErrataApplication.create!(
        host: @host,
        errata_ids: [@erratum.id],
        task: task,
        applied_at: Time.zone.now,
        status: 'success'
      )

      duplicate = ErrataApplication.new(
        host: @host,
        errata_ids: [@erratum.id],
        task: task,
        applied_at: Time.zone.now,
        status: 'success'
      )

      refute duplicate.valid?
      assert_includes duplicate.errors[:task_id], "has already been taken"
    end

    def test_record_from_task_with_valid_task
      task = create_task_with_errata(@host, [@erratum.errata_id])

      applications = ErrataApplication.record_from_task(task, nil)

      assert_equal 1, applications.count
      assert_equal @host.id, applications.first.host_id
      assert_includes applications.first.errata_ids, @erratum.id
      assert_equal 'success', applications.first.status
    end

    def test_record_from_task_with_multiple_errata
      bugfix = katello_errata(:bugfix)
      task = create_task_with_errata(@host, [@erratum.errata_id, bugfix.errata_id])

      applications = ErrataApplication.record_from_task(task, nil)

      assert_equal 1, applications.count
      assert_equal 2, applications.first.errata_ids.count
      assert_includes applications.first.errata_ids, @erratum.id
      assert_includes applications.first.errata_ids, bugfix.id
    end

    def test_record_from_task_returns_empty_for_nil_task
      applications = ErrataApplication.record_from_task(nil, nil)
      assert_empty applications
    end

    def test_record_from_task_returns_empty_for_missing_host
      task = create_task_with_errata(nil, [@erratum.errata_id])

      applications = ErrataApplication.record_from_task(task, nil)
      assert_empty applications
    end

    def test_record_from_task_returns_empty_for_missing_errata
      task = create_task_with_errata(@host, [])

      applications = ErrataApplication.record_from_task(task, nil)
      assert_empty applications
    end

    def test_record_from_task_handles_duplicates
      task = create_task_with_errata(@host, [@erratum.errata_id])

      # Create first application with this task
      ErrataApplication.create!(
        host: @host,
        errata_ids: [@erratum.id],
        task: task,
        applied_at: Time.zone.now,
        status: 'success'
      )

      # Try to record from same task again
      applications = ErrataApplication.record_from_task(task, nil)
      assert_empty applications
    end

    def test_determine_status_from_task_result
      task = create_task_with_errata(@host, [@erratum.errata_id])
      task.update!(result: 'error')

      status = ErrataApplication.determine_status(task, nil)
      assert_equal 'error', status
    end

    def test_determine_status_from_action_error
      task = create_task_with_errata(@host, [@erratum.errata_id])
      task.update!(result: 'pending')
      action = mock('action')
      action.stubs(:error).returns('some error')

      status = ErrataApplication.determine_status(task, action)
      assert_equal 'error', status
    end

    def test_determine_status_defaults_to_success
      task = create_task_with_errata(@host, [@erratum.errata_id])
      task.update!(result: 'pending')
      action = mock('action')
      action.stubs(:error).returns(nil)

      status = ErrataApplication.determine_status(task, action)
      assert_equal 'success', status
    end

    private

    def create_task_with_errata(host, errata_ids)
      input = {}
      if host
        input['host'] = { 'id' => host.id }
      end
      input['errata'] = errata_ids unless errata_ids.empty?

      task = ForemanTasks::Task.create!(
        label: 'Actions::RemoteExecution::RunHostJob',
        state: 'stopped',
        result: 'success',
        started_at: Time.zone.now,
        ended_at: Time.zone.now,
        type: 'ForemanTasks::Task::DynflowTask'
      )

      task.stubs(:input).returns(input)
      task.stubs(:user).returns(@user)
      task
    end
  end
end
