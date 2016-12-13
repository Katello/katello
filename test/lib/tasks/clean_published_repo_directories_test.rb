require 'katello_test_helper'
require 'rake'

module Katello
  class CleanPublishedRepoDirectoriesTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/clean_published_repo_directories'
      Rake.application.rake_require 'katello/tasks/repository'

      Rake::Task['katello:clean_published_repo_directories'].reenable

      Rake::Task.define_task(:environment)

      ENV['COMMIT'] = nil
    end

    def test_repository_republishing
      Dir.stubs(:glob).with('/var/lib/pulp/published/yum/master/*').returns(['Default_Organization-Test-busybox', 'Fedora_17', 'fedora_17_dev_library_view'])
      Dir.stubs(:glob).with('/var/lib/pulp/published/yum/master/yum_distributor/*').returns(['Default_Organization-Test-busybox', 'Default_Organization-Test-ostree', 'fedora_17_dev_library_view'])
      ENV['COMMIT'] = 'true'

      ForemanTasks.expects(:sync_task).with(Actions::Katello::Repository::MetadataGenerate,
                                            Katello::Repository.where(pulp_id: 'Fedora_17').first).returns(ForemanTasks::Task.new)

      Rake.application.invoke_task('katello:clean_published_repo_directories')
    end

    def test_no_repositories_need_republishing
      Dir.stubs(:glob).with('/var/lib/pulp/published/yum/master/*').returns(['Default_Organization-Test-busybox', 'fedora_17_dev_library_view'])
      Dir.stubs(:glob).with('/var/lib/pulp/published/yum/master/yum_distributor/*').returns(['Default_Organization-Test-busybox', 'Default_Organization-Test-ostree', 'fedora_17_dev_library_view'])
      ForemanTasks.expects(:sync_task).never

      Rake.application.invoke_task('katello:clean_published_repo_directories')
    end

    def test_no_publish_option
      Dir.stubs(:glob).with('/var/lib/pulp/published/yum/master/*').returns(['Default_Organization-Test-busybox', 'Fedora_17', 'fedora_17_dev_library_view'])
      Dir.stubs(:glob).with('/var/lib/pulp/published/yum/master/yum_distributor/*').returns(['Default_Organization-Test-busybox', 'Default_Organization-Test-ostree', 'fedora_17_dev_library_view'])

      ForemanTasks.expects(:sync_task).never

      Rake.application.invoke_task('katello:clean_published_repo_directories')
    end
  end
end
