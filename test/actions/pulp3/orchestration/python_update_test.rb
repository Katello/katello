require 'katello_test_helper'

module ::Actions::Pulp3
  class PythonUpdateTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:pulp3_python_1)
      @repo.root.update!(url: 'https://pypi.org', generic_remote_options: {includes: ['pip']}.to_json)
      create_repo(@repo, @primary)

      ForemanTasks.sync_task(
          ::Actions::Katello::Repository::MetadataGenerate, @repo)
      assert_equal 1,
           Katello::Pulp3::DistributionReference.where(repository_id: @repo.id).count,
           "Expected a distribution reference."
    end

    def teardown
      @repo.backend_service(@primary).delete_distributions
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)

      Setting[:completed_pulp_task_protection_days] = 0
      DateTime.expects(:now).returns(DateTime.new(3000, 1, 1))
      ForemanTasks.sync_task(
          ::Actions::Pulp3::Orchestration::OrphanCleanup::RemoveOrphans, @primary)
    end

    def test_download_policy
      @repo.root.update(
        download_policy: 'on_demand')

      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Update,
        @repo,
        @primary)

      python_remote = ::Katello::Pulp3::Api::Generic.new(@primary, ::Katello::RepositoryTypeManager.find('python')).remotes_api
      assert_equal python_remote.list.results.find { |remote| remote.name.include?("pulp3_Python_1") }.policy, "on_demand"
    end
  end
end
