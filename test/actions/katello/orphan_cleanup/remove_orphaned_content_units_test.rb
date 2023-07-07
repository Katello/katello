require 'katello_test_helper'
module Katello
  class RemoveOrphanedContentUnitsTest < ActiveSupport::TestCase
    def setup
      @rhel6 = Repository.find(katello_repositories(:rhel_6_x86_64).id)
    end

    def test_orphaned_content_task_destroys_orphans
      rpm = katello_rpms(:one)
      rpm.repository_rpms.destroy_all
      ForemanTasks.sync_task(Actions::Katello::OrphanCleanup::RemoveOrphanedContentUnits, {repo_id: @rhel6.id})
      assert_raises(ActiveRecord::RecordNotFound) { rpm.reload }
    end

    def test_orphaned_content_task_destroy_all
      rpm = katello_rpms(:one)
      rpm.repository_rpms.destroy_all
      ForemanTasks.sync_task(Actions::Katello::OrphanCleanup::RemoveOrphanedContentUnits, {destroy_all: true})
      assert_raises(ActiveRecord::RecordNotFound) { rpm.reload }
    end
  end
end
