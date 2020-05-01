require 'katello_test_helper'
require_relative 'test_base.rb'
require 'support/pulp/repository_support'

module ::Actions::Pulp::Repository
  class SyncTest < VCRTestBase
    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      super
    end

    def test_sync
      ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync, :repo_id => repo.id).main_action
      assert_equal 18, ::Katello::Pulp::Rpm.ids_for_repository(repo.pulp_id).length
    end
  end
end
