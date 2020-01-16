require 'katello_test_helper'
require 'rake_test_helper'
require 'rake'

module Katello
  class PostPulp3MigrationCheckTest < ActiveSupport::TestCase
    def setup
      @fake_pulp3_href = 'fake_pulp3_href'
      @another_fake_pulp3_href = 'another_fake_pulp3_href'

      Katello::Pulp3::Migration::REPOSITORY_TYPES.each do |type|
        Katello::Repository.with_type(type).each do |repo|
          repo.update(:version_href => @fake_pulp3_href + repo.id.to_s,
                        :remote_href => @fake_pulp3_href + repo.id.to_s,
                        :publication_href => @fake_pulp3_href + repo.id.to_s)
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

      assert_error(@task_name)
    end

    def test_fails_if_file_repository_has_nil_remote_href
      file = katello_repositories(:pulp3_file_1)
      file.update(remote_href: nil)

      assert_error(@task_name)
    end

    def test_fails_if_file_repository_has_nil_publication_href
      file = katello_repositories(:pulp3_file_1)
      file.update(publication_href: nil)

      assert_error(@task_name)
    end

    def test_fails_if_non_archive_file_repository_lacks_a_distribution_reference
      file = katello_repositories(:pulp3_file_1)
      file.update(:remote_href => 'someurl', :version_href => 'someotherurl')

      refute Katello::Pulp3::DistributionReference.exists?(repository_id: file.id)

      assert_error(@task_name)
    end

    def test_passes_if_archive_file_repository_lacks_a_distribution_reference
      Katello::Repository.all.each do |repo|
        Katello::Pulp3::DistributionReference.create!(
          repository_id: repo.id, href: 'somedisthref', path: '/')
      end

      file = katello_repositories(:pulp3_file_1)
      file.update(:remote_href => 'someurl', :version_href => 'someotherurl')
      file.update(:environment => nil)
      Katello::Pulp3::DistributionReference.find_by(repository_id: file.id).delete

      assert file.reload.archive?, "Repository was not an archive repository as expected"
      refute Katello::Pulp3::DistributionReference.exists?(repository_id: file.id)

      Rake::Task[@task_name].invoke
    end

    def test_check_passes_with_non_archive_file_repo_with_distribution_reference
      Katello::Repository.update_all(environment_id: nil)

      file = katello_repositories(:pulp3_file_1)
      file.update(:remote_href => 'someurl', :version_href => 'someotherurl',
                    :environment_id => Katello::KTEnvironment.first.id)

      Katello::Pulp3::DistributionReference.create!(repository_id: file.id, href: 'somedisthref', path: '/')

      refute file.reload.archive?
      assert Katello::Pulp3::DistributionReference.exists?(repository_id: file.id)

      Rake::Task[@task_name].invoke
    end

    def test_fails_if_docker_repository_has_nil_version_href
      docker = katello_repositories(:busybox)
      docker.update(version_href: nil)

      assert_error(@task_name)
    end

    def test_fails_if_docker_repository_has_nil_remote_href
      docker = katello_repositories(:busybox)
      docker.update(remote_href: nil)

      assert_error(@task_name)
    end

    def test_ok_if_docker_repository_has_nil_publication_href
      Katello::Repository.all.each do |repo|
        Katello::Pulp3::DistributionReference.create!(
          repository_id: repo.id, href: 'somedisthref', path: '/')
      end
      docker = katello_repositories(:busybox)
      docker.update(publication_href: nil)

      Rake::Task[@task_name].invoke
    end

    def test_fails_if_non_archive_docker_repository_lacks_a_distribution_reference
      docker = katello_repositories(:busybox)
      docker.update(:remote_href => 'someurl', :version_href => 'someotherurl')

      refute Katello::Pulp3::DistributionReference.exists?(repository_id: docker.id)

      assert_error(@task_name)
    end

    def test_passes_if_archive_docker_repository_lacks_a_distribution_reference
      Katello::Repository.all.each do |repo|
        Katello::Pulp3::DistributionReference.create!(
          repository_id: repo.id, href: 'somedisthref', path: '/')
      end

      docker = katello_repositories(:busybox)
      docker.update(:remote_href => 'someurl', :version_href => 'someotherurl')
      docker.update(:environment => nil)
      Katello::Pulp3::DistributionReference.find_by(repository_id: docker.id).delete

      assert docker.reload.archive?, "Repository was not an archive repository as expected"
      refute Katello::Pulp3::DistributionReference.exists?(repository_id: docker.id)

      Rake::Task[@task_name].invoke
    end

    def test_check_passes_with_non_archive_docker_repo_with_distribution_reference
      Katello::Repository.update_all(environment_id: nil)

      docker = katello_repositories(:busybox)
      docker.update(:remote_href => 'someurl', :version_href => 'someotherurl',
                    :environment_id => Katello::KTEnvironment.first.id)

      Katello::Pulp3::DistributionReference.create!(repository_id: docker.id, href: 'somedisthref', path: '/')

      refute docker.reload.archive?
      assert Katello::Pulp3::DistributionReference.exists?(repository_id: docker.id)

      Rake::Task[@task_name].invoke
    end
  end
end
