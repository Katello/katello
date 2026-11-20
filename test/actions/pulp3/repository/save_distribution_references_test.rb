require 'katello_test_helper'

module ::Actions::Pulp3::Repository
  class SaveDistributionReferencesTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction

    def setup
      stub_remote_user
      @repo = katello_repositories(:pulp3_docker_1)
      @proxy = SmartProxy.pulp_primary
      @service = mock('backend service')
      @repo.stubs(:backend_service).returns(@service)
      ::Katello::Repository.stubs(:find).with(@repo.id).returns(@repo)
    end

    def plan_with(tasks, href = '/pulp/distributions/old/', options = {})
      @service.stubs(:distribution_reference).returns(href ? stub(href: href) : nil)
      create_and_plan_action(::Actions::Pulp3::Repository::SaveDistributionReferences, @repo, @proxy, tasks, options)
    end

    def test_update_without_created_resources_reconciles_captured_href
      action = plan_with(pulp_tasks: [{created_resources: []}])
      @service.expects(:save_distribution_references).with(['/pulp/distributions/old/'])
      @service.expects(:update_distribution).never
      run_action(action)
    end

    def test_noop_reconciles_captured_href
      action = plan_with(pulp_tasks: [])
      @service.expects(:save_distribution_references).with(['/pulp/distributions/old/'])
      run_action(action)
    end

    def test_created_resource_takes_precedence_over_stale_reference
      action = plan_with(pulp_tasks: [{created_resources: ['/pulp/distributions/new/']}])
      @service.expects(:save_distribution_references).with(['/pulp/distributions/new/'])
      run_action(action)
    end

    def test_existing_only_ignores_created_resources_and_reconciles_captured_href
      action = plan_with({pulp_tasks: [{created_resources: ['/pulp/remotes/new/']}]},
                         '/pulp/distributions/old/', existing_only: true)
      @service.expects(:save_distribution_references).with(['/pulp/distributions/old/'])
      run_action(action)
    end

    def test_existing_only_does_not_reconcile_if_reference_changed
      action = plan_with({pulp_tasks: [{created_resources: ['/pulp/remotes/new/']}]},
                         '/pulp/distributions/old/', existing_only: true)
      @service.stubs(:distribution_reference).returns(stub(href: '/pulp/distributions/other/'))
      @service.expects(:save_distribution_references).never
      run_action(action)
    end

    def test_existing_only_does_not_reconcile_without_captured_reference
      action = plan_with({pulp_tasks: [{created_resources: ['/pulp/remotes/new/']}]}, nil, existing_only: true)
      @service.expects(:save_distribution_references).never
      run_action(action)
    end

    def test_no_reference_and_no_tasks_does_not_guess_a_distribution
      action = plan_with({pulp_tasks: []}, nil)
      @service.expects(:save_distribution_references).never
      run_action(action)
    end
  end
end
