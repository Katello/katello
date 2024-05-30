require 'katello_test_helper'
require 'rake'

module Katello
  class DeleteOrphanedContentTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/delete_orphaned_content'
      Rake::Task['katello:delete_orphaned_content'].reenable
      Rake::Task.define_task(:environment)
      Rake::Task.define_task('dynflow:client')
      @primary = SmartProxy.pulp_primary
      @mirror = FactoryBot.create(:smart_proxy, :pulp_mirror)
    end

    def test_delete_orphaned_content_without_params
      ENV.delete('SMART_PROXY_ID') if ENV['SMART_PROXY_ID']
      smart_proxies = [@primary, @mirror]
      ForemanTasks.expects(:async_task).twice.with do |main_task, parsed_stack|
        assert_equal(::Actions::Katello::OrphanCleanup::RemoveOrphans, main_task)
        assert_includes smart_proxies, parsed_stack
        smart_proxies.delete parsed_stack
      end

      Setting[:completed_pulp_task_protection_days] = 0
      Rake.application.invoke_task('katello:delete_orphaned_content')
    end

    def test_delete_orphaned_content_with_param
      ENV['SMART_PROXY_ID'] = @mirror.id.to_s
      ForemanTasks.expects(:async_task).once.with do |main_task, parsed_stack|
        assert_equal(::Actions::Katello::OrphanCleanup::RemoveOrphans, main_task)
        assert_equal @mirror, parsed_stack
      end

      Setting[:completed_pulp_task_protection_days] = 0
      Rake.application.invoke_task('katello:delete_orphaned_content')
    end
  end
end
