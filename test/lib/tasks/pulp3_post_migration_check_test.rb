require 'katello_test_helper'
require 'rake'

module Katello
  class PostPulp3MigrationCheckTest < ActiveSupport::TestCase
    def capture_out(&block)
       original_stdout = $stdout
       original_stderr = $stderr
       $stdout = fakeout = StringIO.new
       $stderr = fakeerr = StringIO.new
       begin
         yield
       ensure
         $stdout = original_stdout
         @stderr = original_stderr
       end
       [fakeout.string, fakeerr.string]
    end

    def asserts_error(task_name, exit_code = 1)
      result = assert_raises SystemExit do
        outs = capture_out do
          Rake::Task[task_name].invoke
        end
      end
      assert_equal exit_code, result.status
    end

    def setup
      @fake_pulp3_href = 'fake_pulp3_href'
      @another_fake_pulp3_href = 'another_fake_pulp3_href'

      Katello::Pulp3::Migration::REPOSITORY_TYPES.each do |type|
        Katello::Repository.with_type(type).each do |repo|
          repo.update(:version_href => @fake_pulp3_href + repo.id.to_s,
                        :remote_href => @fake_pulp3_href + repo.id.to_s)
        end
      end

      Rake.application.rake_require 'katello/tasks/pulp3_post_migration_check'
      @task_name = 'katello:pulp3_post_migration_check'
      Rake::Task[@task_name].reenable
      Rake::Task.define_task(:environment)
    end

    def test_fails_if_file_repository_has_nil_version_href
      file = katello_repositories(:pulp3_file_1)
      file.update(version_href: nil)

      asserts_error(@task_name)
    end

    def test_fails_if_file_repository_has_nil_remote_href
      file = katello_repositories(:pulp3_file_1)
      file.update(remote_href: nil)

      asserts_error(@task_name)
    end

    def test_fails_if_docker_repository_has_nil_version_href
      docker = FactoryBot.create(:docker_repository)
    end

  end
end
