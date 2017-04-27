require 'katello_test_helper'
require 'rake'

module Katello
  class RepositoryTaskTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/repository'
      Rake.application.rake_require 'katello/tasks/reimport'

      Rake::Task['katello:regenerate_repo_metadata'].reenable
      Rake::Task['katello:refresh_pulp_repo_details'].reenable
      Rake::Task['katello:correct_repositories'].reenable
      Rake::Task['katello:disable_dynflow'].reenable
      Rake::Task['katello:correct_puppet_environments'].reenable
      Rake::Task['katello:check_ping'].reenable
      Rake::Task['katello:change_download_policy'].reenable
      Katello::Ping.expects(:ping).returns(:status => 'ok')

      Rake::Task.define_task(:environment)

      @library_repo = katello_repositories(:fedora_17_x86_64)
      @cv_repo = katello_repositories(:fedora_17_dev_library_view)

      @puppet_env = katello_content_view_puppet_environments(:dev_view_puppet_environment)

      Katello::Repository.where("id not in (#{@library_repo.id},#{@cv_repo.id})").destroy_all
      Katello::ContentViewPuppetEnvironment.where("id != #{@puppet_env.id}").destroy_all
      ENV['COMMIT'] = nil
      ENV['CONTENT_VIEW'] = nil
      ENV['LIFECYCLE_ENVIRONMENT'] = nil
    end

    def test_regenerate_repo_metadata
      ForemanTasks.expects(:async_task).with(::Actions::BulkAction, Actions::Katello::Repository::MetadataGenerate,
                                             Katello::Repository.all.sort).returns(ForemanTasks::Task.new)

      Rake.application.invoke_task('katello:regenerate_repo_metadata')
    end

    def test_regenerate_repo_metadata_env
      ENV['LIFECYCLE_ENVIRONMENT'] = @library_repo.environment.name

      expected_repos = Katello::Repository.joins(:environment).where('katello_environments.name' => @library_repo.environment.name)
      ForemanTasks.expects(:async_task).with(::Actions::BulkAction, Actions::Katello::Repository::MetadataGenerate,
                                             expected_repos.sort).returns(ForemanTasks::Task.new)

      Rake.application.invoke_task('katello:regenerate_repo_metadata')
    end

    def test_regenerate_repo_metadata_cv
      ENV['CONTENT_VIEW'] = @cv_repo.content_view.name
      ForemanTasks.expects(:async_task).with(::Actions::BulkAction, Actions::Katello::Repository::MetadataGenerate,
                                             [@cv_repo]).returns(ForemanTasks::Task.new)

      Rake.application.invoke_task('katello:regenerate_repo_metadata')
    end

    def test_refresh_pulp_repo_details
      ForemanTasks.expects(:async_task).with(::Actions::BulkAction, Actions::Katello::Repository::RefreshRepository,
                                             Katello::Repository.all.sort).returns(ForemanTasks::Task.new)

      Rake.application.invoke_task('katello:refresh_pulp_repo_details')
    end

    def test_correct_repositories
      ENV['CONTENT_VIEW'] = @cv_repo.content_view.name
      Runcible::Extensions::Repository.any_instance.expects(:retrieve).once.with(@cv_repo.pulp_id).returns({})

      ForemanTasks.expects(:sync_task).never

      Rake.application.invoke_task('katello:correct_repositories')
    end

    def test_correct_repositories_missing_cv_repo
      ENV['CONTENT_VIEW'] = @cv_repo.content_view.name
      Runcible::Extensions::Repository.any_instance.expects(:retrieve).once.with(@cv_repo.pulp_id).raises(RestClient::ResourceNotFound)

      ForemanTasks.expects(:sync_task).never

      Rake.application.invoke_task('katello:correct_repositories')
    end

    def test_correct_repositories_missing_cv_repo_commit
      ENV['CONTENT_VIEW'] = @cv_repo.content_view.name
      ENV['COMMIT'] = 'true'
      Runcible::Extensions::Repository.any_instance.expects(:retrieve).once.with(@cv_repo.pulp_id).raises(RestClient::ResourceNotFound)

      ForemanTasks.expects(:sync_task).with(::Actions::Katello::Repository::Destroy, @cv_repo, :planned_destroy => true)

      Rake.application.invoke_task('katello:correct_repositories')
    end

    def test_correct_repositories_missing_library_repo_commit
      ENV['LIFECYCLE_ENVIRONMENT'] = @library_repo.environment.name
      ENV['COMMIT'] = 'true'

      Katello::Repository.stubs(:in_environment).returns(Katello::Repository.where(:id => @library_repo))
      Runcible::Extensions::Repository.any_instance.expects(:retrieve).once.with(@library_repo.pulp_id).raises(RestClient::ResourceNotFound)

      ForemanTasks.expects(:sync_task).with(::Actions::Katello::Repository::Create, @library_repo)

      Rake.application.invoke_task('katello:correct_repositories')
    end

    def test_correct_puppet_environments
      ENV['CONTENT_VIEW'] = @puppet_env.content_view.name
      Runcible::Extensions::Repository.any_instance.expects(:retrieve).once.with(@puppet_env.pulp_id).returns({})

      ForemanTasks.expects(:sync_task).never

      Rake.application.invoke_task('katello:correct_puppet_environments')
    end

    def test_correct_puppet_environments_missing
      ENV['CONTENT_VIEW'] = @puppet_env.content_view.name
      Runcible::Extensions::Repository.any_instance.expects(:retrieve).once.with(@puppet_env.pulp_id).raises(RestClient::ResourceNotFound)

      ForemanTasks.expects(:sync_task).never
      Rake.application.invoke_task('katello:correct_puppet_environments')
    end

    def test_correct_puppet_environments_missing_commit
      ENV['COMMIT'] = 'true'
      ENV['CONTENT_VIEW'] = @puppet_env.content_view.name
      Runcible::Extensions::Repository.any_instance.expects(:retrieve).once.with(@puppet_env.pulp_id).raises(RestClient::ResourceNotFound)

      ForemanTasks.expects(:sync_task).with(::Actions::Katello::ContentViewPuppetEnvironment::Create, @puppet_env)

      Rake.application.invoke_task('katello:correct_puppet_environments')
    end

    def test_change_download_policy
      ENV['DOWNLOAD_POLICY'] = 'background'
      Katello::Repository.stubs(:yum_type).returns(Katello::Repository.where(:id => @library_repo))
      ForemanTasks.expects(:sync_task).with(::Actions::Katello::Repository::Update,
                                            @library_repo,
                                            download_policy: 'background')

      Rake.application.invoke_task('katello:change_download_policy')
    end

    def test_change_download_policy_bad_policy
      ForemanTasks.expects(:sync_task).never

      ENV['DOWNLOAD_POLICY'] = nil
      Rake.application.invoke_task('katello:change_download_policy')

      ENV['DOWNLOAD_POLICY'] = 'invalid'
      Rake.application.invoke_task('katello:change_download_policy')
    end
  end
end
