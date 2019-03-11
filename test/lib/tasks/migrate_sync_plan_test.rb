require 'katello_test_helper'
require 'rake'

module Katello
  class MigrateSyncPlanTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/3.9/migrate_sync_plans'
      Rake::Task['katello:upgrades:3.9:migrate_sync_plans'].reenable
      Rake::Task.define_task(:environment)
      @organization = get_organization
      @plan = SyncPlan.new(:name => 'Norman Rockwell', :organization => @organization, :sync_date => Time.now, :interval => 'daily')
      @plan.save!
    end

    def test_migrate_sync_plans
      assert_nil @plan.foreman_tasks_recurring_logic
      Rake.application.invoke_task('katello:upgrades:3.9:migrate_sync_plans')
      assert_migration_successful @plan
    end

    def test_disabled_sync_plan_migration
      @plan[:enabled] = false
      @plan.save!
      assert_nil @plan.foreman_tasks_recurring_logic
      Rake.application.invoke_task('katello:upgrades:3.9:migrate_sync_plans')
      assert_migration_successful @plan
    end

    def test_pulp_schedule_deletion
      product = katello_products(:redhat)
      @plan.products << product
      assert_nil @plan.foreman_tasks_recurring_logic
      Runcible::Extensions::Repository.any_instance.expects(:remove_schedules).times(3).returns("success!!")
      Rake.application.invoke_task('katello:upgrades:3.9:migrate_sync_plans')
      assert_migration_successful @plan
    end

    def assert_migration_successful(sync_plan)
      sync_plan.reload
      assert_not_nil sync_plan.foreman_tasks_recurring_logic
    end
  end
end
