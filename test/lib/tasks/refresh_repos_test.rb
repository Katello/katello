require 'katello_test_helper'
require 'rake'

module Katello
  class RefreshReposTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/refresh_repos'
      Rake::Task['katello:refresh_repos'].reenable
      Rake::Task.define_task(:environment)
      Rake::Task.define_task('dynflow:client')
    end

    def test_refresh_repos_on_smart_proxies
      ::ForemanTasks.expects(:async_task).with(::Actions::BulkAction, ::Actions::Pulp3::Orchestration::Repository::RefreshRepos, SmartProxy.all)
      Rake.application.invoke_task('katello:refresh_repos')
    end
  end
end
