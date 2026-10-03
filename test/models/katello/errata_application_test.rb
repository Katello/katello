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
        errata_ids: [@erratum.errata_id],
        applied_at: Time.zone.now,
        status: 'success',
        user: @user
      )

      assert application.valid?
      assert_equal @host.id, application.host_id
      assert_includes application.errata_ids, @erratum.errata_id
      assert_equal 'success', application.status
    end

    def test_requires_host
      application = ErrataApplication.new(
        errata_ids: [@erratum.errata_id],
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
        errata_ids: [@erratum.errata_id]
      )

      refute application.valid?
      assert_includes application.errors[:applied_at], "can't be blank"
    end

    def test_requires_status
      application = ErrataApplication.new(
        host: @host,
        errata_ids: [@erratum.errata_id],
        applied_at: Time.zone.now,
        status: nil
      )

      refute application.valid?
      assert_includes application.errors[:status], "can't be blank"
    end

    def test_validates_status_inclusion
      application = ErrataApplication.new(
        host: @host,
        errata_ids: [@erratum.errata_id],
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
        errata_ids: [@erratum.errata_id],
        task: task,
        applied_at: Time.zone.now,
        status: 'success'
      )

      duplicate = ErrataApplication.new(
        host: @host,
        errata_ids: [@erratum.errata_id],
        task: task,
        applied_at: Time.zone.now,
        status: 'success'
      )

      refute duplicate.valid?
      assert_includes duplicate.errors[:task_id], "has already been taken"
    end

    def test_record_from_task_with_valid_task
      task = create_task_with_errata(@host, [@erratum.errata_id])

      application = ErrataApplication.record_from_task(task, nil)

      assert_not_nil application
      assert_equal @host.id, application.host_id
      assert_includes application.errata_ids, @erratum.errata_id
      assert_equal 'success', application.status
    end

    def test_record_from_task_with_multiple_errata
      bugfix = katello_errata(:bugfix)
      task = create_task_with_errata(@host, [@erratum.errata_id, bugfix.errata_id])

      application = ErrataApplication.record_from_task(task, nil)

      assert_not_nil application
      assert_equal 2, application.errata_ids.count
      assert_includes application.errata_ids, @erratum.errata_id
      assert_includes application.errata_ids, bugfix.errata_id
    end

    def test_record_from_task_returns_nil_for_nil_task
      application = ErrataApplication.record_from_task(nil, nil)
      assert_nil application
    end

    def test_record_from_task_returns_nil_for_missing_host
      task = create_task_with_errata(nil, [@erratum.errata_id])

      application = ErrataApplication.record_from_task(task, nil)
      assert_nil application
    end

    def test_record_from_task_returns_nil_for_missing_errata
      task = create_task_with_errata(@host, [])

      application = ErrataApplication.record_from_task(task, nil)
      assert_nil application
    end

    def test_record_from_task_handles_duplicates
      task = create_task_with_errata(@host, [@erratum.errata_id])

      # Create first application with this task
      ErrataApplication.create!(
        host: @host,
        errata_ids: [@erratum.errata_id],
        task: task,
        applied_at: Time.zone.now,
        status: 'success'
      )

      # Try to record from same task again
      application = ErrataApplication.record_from_task(task, nil)
      assert_nil application
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

    def test_record_from_task_with_package_update_job
      task = create_task_for_package_update(@host, 'foobar')

      erratum_scope = Katello::Erratum.where(errata_id: @erratum.errata_id)
      Katello::Erratum.stubs(:installable_for_hosts).with([@host]).returns(erratum_scope)

      application = ErrataApplication.record_from_task(task, nil)

      assert_not_nil application
      assert_equal @host.id, application.host_id
      assert_includes application.errata_ids, @erratum.errata_id
      assert_equal 'success', application.status
    end

    def test_record_from_task_with_package_update_no_matching_errata
      task = create_task_for_package_update(@host, 'nonexistent-package')

      erratum_scope = Katello::Erratum.where(errata_id: @erratum.errata_id)
      Katello::Erratum.stubs(:installable_for_hosts).with([@host]).returns(erratum_scope)

      application = ErrataApplication.record_from_task(task, nil)

      assert_nil application
    end

    def test_record_from_task_with_package_update_all
      task = create_task_for_package_update(@host, '')

      erratum_scope = Katello::Erratum.where(errata_id: [@erratum.errata_id])
      Katello::Erratum.stubs(:installable_for_hosts).with([@host]).returns(erratum_scope)

      application = ErrataApplication.record_from_task(task, nil)

      assert_not_nil application
      assert_includes application.errata_ids, @erratum.errata_id
    end

    def test_record_from_task_with_package_update_no_content_facet
      host_without_facet = ::Host::Managed.create!(name: 'no-facet-host', managed: false)
      task = create_task_for_package_update(host_without_facet, 'foobar')

      application = ErrataApplication.record_from_task(task, nil)

      assert_nil application
    ensure
      host_without_facet&.destroy
    end

    def test_record_from_task_with_package_update_by_search
      task = create_task_for_package_update_by_search(@host, 'name = foobar')

      erratum_scope = Katello::Erratum.where(errata_id: @erratum.errata_id)
      Katello::Erratum.stubs(:installable_for_hosts).with([@host]).returns(erratum_scope)

      installed_scope = mock('installed_scope')
      installed_scope.stubs(:distinct).returns(installed_scope)
      installed_scope.stubs(:pluck).with(:name).returns(['foobar'])
      @host.stubs(:installed_packages).returns(mock('packages_assoc'))
      @host.installed_packages.stubs(:search_for).with('name = foobar').returns(installed_scope)

      application = ErrataApplication.record_from_task(task, nil)

      assert_not_nil application
      assert_includes application.errata_ids, @erratum.errata_id
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

      # Stub dynflow_initialized? to return true so tests can use task.input
      ErrataApplication.stubs(:dynflow_initialized?).returns(true)

      task
    end

    def create_task_for_package_update(host, package_input)
      input = {}
      input['host'] = { 'id' => host.id } if host
      input['job_features'] = ['katello_package_update']

      task = create_base_task(input)
      stub_template_invocation(task, host)
      stub_template_input_values(998, 'package' => package_input.presence, 'Packages search query' => nil)

      ErrataApplication.stubs(:dynflow_initialized?).returns(true)

      task
    end

    def create_task_for_package_update_by_search(host, search_query)
      input = {}
      input['host'] = { 'id' => host.id } if host
      input['job_features'] = ['katello_packages_update_by_search']

      task = create_base_task(input)
      stub_template_invocation(task, host)
      stub_template_input_values(998, 'package' => nil, 'Packages search query' => search_query)

      ErrataApplication.stubs(:dynflow_initialized?).returns(true)

      task
    end

    def create_base_task(input)
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

    def stub_template_invocation(task, host)
      template_invocation = mock('template_invocation')
      template_invocation.stubs(:id).returns(998)
      template_invocation.stubs(:host_id).returns(host&.id)
      task.stubs(:template_invocation).returns(template_invocation)
    end

    def stub_template_input_values(invocation_id, inputs)
      ::TemplateInvocationInputValue.stubs(:joins).returns(::TemplateInvocationInputValue)
      ::TemplateInvocationInputValue.stubs(:where).with(template_invocation_id: invocation_id).returns(::TemplateInvocationInputValue)

      inputs.each do |name, value|
        query = mock("query_#{name}")
        if value
          result = mock("result_#{name}")
          result.stubs(:value).returns(value)
          query.stubs(:first).returns(result)
        else
          query.stubs(:first).returns(nil)
        end
        ::TemplateInvocationInputValue.stubs(:where).with("template_inputs.name = ?", name).returns(query)
      end
    end
  end
end
