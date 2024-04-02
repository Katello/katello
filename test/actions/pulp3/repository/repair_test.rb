require 'katello_test_helper'

module ::Actions::Pulp3::Repository
  class RepairTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      User.current = users(:admin)
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.root.update!(url: 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')
      create_repo(@repo, @primary)
      ForemanTasks.sync_task(
        ::Actions::Katello::Repository::MetadataGenerate, @repo)
    end

    def teardown
      User.current = users(:admin)
      ForemanTasks.sync_task(
        ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
    end

    def test_repair_task_succeeds
      task = ForemanTasks.sync_task(::Actions::Pulp3::Repository::Repair,
                                     @repo.id, @primary)
      assert_equal task.result, "success"
    end
  end
end
