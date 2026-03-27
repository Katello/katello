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
        erratum: @erratum,
        applied_at: Time.zone.now,
        status: 'success',
        method: 'remote_execution',
        user: @user
      )

      assert application.valid?
      assert_equal @host.id, application.host_id
      assert_equal @erratum.id, application.erratum_id
      assert_equal 'success', application.status
      assert_equal 'remote_execution', application.method
    end

    def test_requires_host
      application = ErrataApplication.new(
        erratum: @erratum,
        applied_at: Time.zone.now,
        status: 'success',
        method: 'remote_execution'
      )

      refute application.valid?
      assert_includes application.errors[:host], "can't be blank"
    end

    def test_requires_erratum
      application = ErrataApplication.new(
        host: @host,
        applied_at: Time.zone.now,
        status: 'success',
        method: 'remote_execution'
      )

      refute application.valid?
      assert_includes application.errors[:erratum], "can't be blank"
    end

    def test_requires_applied_at
      application = ErrataApplication.new(
        host: @host,
        erratum: @erratum,
        status: 'success',
        method: 'remote_execution'
      )

      refute application.valid?
      assert_includes application.errors[:applied_at], "can't be blank"
    end

    def test_requires_status
      application = ErrataApplication.new(
        host: @host,
        erratum: @erratum,
        applied_at: Time.zone.now,
        method: 'remote_execution',
        status: nil
      )

      refute application.valid?
      assert_includes application.errors[:status], "can't be blank"
    end

    def test_requires_method
      application = ErrataApplication.new(
        host: @host,
        erratum: @erratum,
        applied_at: Time.zone.now,
        status: 'success',
        method: nil
      )

      refute application.valid?
      assert_includes application.errors[:method], "can't be blank"
    end

    def test_validates_status_inclusion
      application = ErrataApplication.new(
        host: @host,
        erratum: @erratum,
        applied_at: Time.zone.now,
        status: 'invalid_status',
        method: 'remote_execution'
      )

      refute application.valid?
      assert_includes application.errors[:status], "is not included in the list"
    end

    def test_validates_method_inclusion
      application = ErrataApplication.new(
        host: @host,
        erratum: @erratum,
        applied_at: Time.zone.now,
        status: 'success',
        method: 'invalid_method'
      )

      refute application.valid?
      assert_includes application.errors[:method], "is not included in the list"
    end

    def test_uniqueness_constraint
      applied_at = Time.zone.now
      ErrataApplication.create!(
        host: @host,
        erratum: @erratum,
        applied_at: applied_at,
        status: 'success',
        method: 'remote_execution'
      )

      duplicate = ErrataApplication.new(
        host: @host,
        erratum: @erratum,
        applied_at: applied_at,
        status: 'error',
        method: 'manual'
      )

      refute duplicate.valid?
      assert_includes duplicate.errors[:erratum_id], "has already been taken"
    end

    def test_successful_scope
      ErrataApplication.create!(
        host: @host,
        erratum: @erratum,
        applied_at: Time.zone.now,
        status: 'success',
        method: 'remote_execution'
      )

      assert_includes ErrataApplication.successful, ErrataApplication.last
    end

    def test_failed_scope
      failed_app = ErrataApplication.create!(
        host: @host,
        erratum: @erratum,
        applied_at: Time.zone.now,
        status: 'error',
        method: 'remote_execution'
      )

      assert_includes ErrataApplication.failed, failed_app
    end

    def test_since_scope
      old_app = ErrataApplication.create!(
        host: @host,
        erratum: @erratum,
        applied_at: 2.days.ago,
        status: 'success',
        method: 'remote_execution'
      )

      new_app = ErrataApplication.create!(
        host: @host,
        erratum: katello_errata(:bugfix),
        applied_at: Time.zone.now,
        status: 'success',
        method: 'remote_execution'
      )

      applications = ErrataApplication.since(1.day.ago)
      assert_includes applications, new_app
      refute_includes applications, old_app
    end

    def test_up_to_scope
      old_app = ErrataApplication.create!(
        host: @host,
        erratum: @erratum,
        applied_at: 2.days.ago,
        status: 'success',
        method: 'remote_execution'
      )

      new_app = ErrataApplication.create!(
        host: @host,
        erratum: katello_errata(:bugfix),
        applied_at: Time.zone.now,
        status: 'success',
        method: 'remote_execution'
      )

      applications = ErrataApplication.up_to(1.day.ago)
      assert_includes applications, old_app
      refute_includes applications, new_app
    end

    def test_by_method_scope
      rex_app = ErrataApplication.create!(
        host: @host,
        erratum: @erratum,
        applied_at: Time.zone.now,
        status: 'success',
        method: 'remote_execution'
      )

      manual_app = ErrataApplication.create!(
        host: @host,
        erratum: katello_errata(:bugfix),
        applied_at: Time.zone.now,
        status: 'success',
        method: 'manual'
      )

      applications = ErrataApplication.by_method('remote_execution')
      assert_includes applications, rex_app
      refute_includes applications, manual_app
    end

    def test_record_from_task_with_valid_task
      task = create_task_with_errata(@host, [@erratum.errata_id])

      applications = ErrataApplication.record_from_task(task)

      assert_equal 1, applications.count
      assert_equal @host.id, applications.first.host_id
      assert_equal @erratum.id, applications.first.erratum_id
      assert_equal 'success', applications.first.status
      assert_equal 'remote_execution', applications.first.method
    end

    def test_record_from_task_returns_empty_for_nil_task
      applications = ErrataApplication.record_from_task(nil)
      assert_empty applications
    end

    def test_record_from_task_returns_empty_for_invalid_state
      task = create_task_with_errata(@host, [@erratum.errata_id])
      task.update!(state: 'scheduled')

      applications = ErrataApplication.record_from_task(task)
      assert_empty applications
    end

    def test_record_from_task_returns_empty_for_missing_host
      task = create_task_with_errata(nil, [@erratum.errata_id])

      applications = ErrataApplication.record_from_task(task)
      assert_empty applications
    end

    def test_record_from_task_returns_empty_for_missing_errata
      task = create_task_with_errata(@host, [])

      applications = ErrataApplication.record_from_task(task)
      assert_empty applications
    end

    def test_record_from_task_handles_duplicates
      applied_at = Time.zone.now
      ErrataApplication.create!(
        host: @host,
        erratum: @erratum,
        applied_at: applied_at,
        status: 'success',
        method: 'remote_execution'
      )

      task = create_task_with_errata(@host, [@erratum.errata_id])
      task.update!(ended_at: applied_at)

      applications = ErrataApplication.record_from_task(task)
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

    def test_determine_method_remote_execution
      task = create_task_with_errata(@host, [@erratum.errata_id])
      task.update!(label: 'Actions::RemoteExecution::RunHostJob')

      method = ErrataApplication.determine_method_from_task(task)
      assert_equal 'remote_execution', method
    end

    def test_determine_method_katello_agent
      task = create_task_with_errata(@host, [@erratum.errata_id])
      task.update!(label: 'Actions::Katello::Host::Erratum::Install')

      method = ErrataApplication.determine_method_from_task(task)
      assert_equal 'katello_agent', method
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
