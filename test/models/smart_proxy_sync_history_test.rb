require 'katello_test_helper'

module Katello
  class SmartProxySyncHistoryTest < ActiveSupport::TestCase
    include Support::CapsuleSupport

    def setup
      super
      User.current = @admin
      @repo = katello_repositories(:rhel_6_x86_64)
    end

    def test_create_on_repo
      assert_equal @repo.smart_proxy_sync_histories.count, 0
      spsh_id = @repo.create_smart_proxy_sync_history proxy_with_pulp
      assert_equal @repo.smart_proxy_sync_histories.count, 1
      repo_spsh = ::Katello::SmartProxySyncHistory.find(spsh_id)
      assert_equal repo_spsh.smart_proxy_id, proxy_with_pulp.id
      assert_equal repo_spsh.repository_id, @repo.id
    end

    def test_clear_on_repo
      @repo.create_smart_proxy_sync_history proxy_with_pulp
      assert_equal @repo.smart_proxy_sync_histories.count, 1
      @repo.clear_smart_proxy_sync_histories
      assert_equal @repo.smart_proxy_sync_histories.count, 0
    end

    def test_repo_smart_proxy_history_unique
      @repo.create_smart_proxy_sync_history proxy_with_pulp
      assert_equal @repo.smart_proxy_sync_histories.count, 1
      sp_history_args = {
        :smart_proxy_id => proxy_with_pulp.id,
        :repository_id => @repo.id,
        :started_at => Time.now
      }
      assert_raises(ActiveRecord::RecordNotUnique) do
        ::Katello::SmartProxySyncHistory.create sp_history_args
      end
    end

    def test_clear_history_on_smart_proxy
      smart_proxy_helper = ::Katello::SmartProxyHelper.new(proxy_with_pulp)
      @repo.create_smart_proxy_sync_history proxy_with_pulp
      assert_equal @repo.smart_proxy_sync_histories.count, 1
      smart_proxy_helper.clear_smart_proxy_sync_histories [@repo]
      assert_equal @repo.smart_proxy_sync_histories.count, 0
      @repo.create_smart_proxy_sync_history proxy_with_pulp
      assert_equal @repo.smart_proxy_sync_histories.count, 1
      smart_proxy_helper.clear_smart_proxy_sync_histories
      assert_equal @repo.smart_proxy_sync_histories.count, 0
    end

    def test_clear_history_on_publish_repositories
      User.current = users(:admin)
      busybox = katello_repositories(:busybox)
      busybox.create_smart_proxy_sync_history(proxy_with_pulp)
      library = katello_environments(:library)
      library.expects(:repositories).returns(::Katello::Repository.where(id: busybox.id))
      ::Actions::Katello::Environment::PublishContainerRepositories.any_instance.expects(:plan_action).twice
      ::ForemanTasks.sync_task(::Actions::Katello::Environment::PublishContainerRepositories, library)
      assert_equal busybox.smart_proxy_sync_histories.count, 0
    end
  end
end
