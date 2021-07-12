require 'katello_test_helper'

module ::Actions::Pulp3
  class YumRefreshIfNeededTest < ActiveSupport::TestCase
    include Katello::Pulp3Support

    def setup
      @smart_proxy = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
      @repo = katello_repositories(:fedora_17_x86_64_duplicate)
      @repo.root.update_attribute(:unprotected, true)

      create_repo(@repo, @smart_proxy)
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::GenerateMetadata, @repo, @smart_proxy)
    end

    def teardown
      ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @smart_proxy)
    end

    def test_refresh_if_needed
      action = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::RefreshIfNeeded, @repo, @smart_proxy)
      refute_empty action.output[:pulp_tasks]
    end
  end
end
