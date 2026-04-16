require 'katello_test_helper'
require 'rake'

module Katello
  class CleanupPythonPublicationsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/4.21/cleanup_python_publications'
      Rake::Task['katello:upgrades:4.21:cleanup_python_publications'].reenable
      Rake::Task.define_task(:environment)
      Rake::Task.define_task('katello:check_ping')
      User.current = User.find(users(:admin).id)
    end

    def setup_common_mocks
      Katello::Pulp3::Repository.stubs(:instance_for_type).returns(nil)
      tasks_api_mock = mock('tasks_api')
      Katello::Pulp3::Api::Core.any_instance.stubs(:tasks_api).returns(tasks_api_mock)
    end

    def test_cleanup_with_no_publications
      setup_common_mocks

      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([])

      assert_nothing_raised do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
    end

    def test_cleanup_deletes_publications
      setup_common_mocks

      pub1 = OpenStruct.new(pulp_href: '/pulp/api/v3/publications/python/pypi/abc123/')
      pub2 = OpenStruct.new(pulp_href: '/pulp/api/v3/publications/python/pypi/def456/')
      publications_api_mock = mock('publications_api')
      publications_api_mock.expects(:delete).with(pub1.pulp_href).once
      publications_api_mock.expects(:delete).with(pub2.pulp_href).once
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([pub1, pub2])
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_api).returns(publications_api_mock)

      assert_nothing_raised do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
    end

    def test_cleanup_clears_publication_href_from_repositories
      python_repos = Katello::Repository.joins(:root).where(katello_root_repositories: { content_type: 'python' })
      repo = python_repos.first
      # Use update_column to bypass validations and callbacks
      repo.update_column(:publication_href, '/pulp/api/v3/publications/python/pypi/test123/')
      assert_not_nil repo.reload.publication_href

      # Mock the distribution migration since repo has publication_href but no environment
      # so it won't be selected for migration
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([])

      Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      assert_nil repo.reload.publication_href
    end

    def test_cleanup_handles_404_errors_gracefully
      setup_common_mocks

      pub1 = OpenStruct.new(pulp_href: '/pulp/api/v3/publications/python/pypi/already-deleted/')
      publications_api_mock = mock('publications_api')
      publications_api_mock.expects(:delete).with(pub1.pulp_href).raises(RestClient::NotFound)
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([pub1])
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_api).returns(publications_api_mock)

      # Should handle the 404 gracefully and continue without raising
      assert_nothing_raised do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
    end

    def test_cleanup_handles_api_list_failure
      setup_common_mocks

      error_message = "Connection to Pulp failed"
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).raises(StandardError.new(error_message))

      exit_error = assert_raises(SystemExit) do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
      assert_equal 1, exit_error.status
    end

    def test_migrates_distributions_before_deleting_publications
      python_repos = Katello::Repository.joins(:root).where(katello_root_repositories: { content_type: 'python' })
      repo = python_repos.first
      # Use update_column to set publication_href in database
      repo.update_column(:publication_href, '/pulp/api/v3/publications/python/pypi/old-pub/')
      repo.stubs(:environment).returns(mock('environment'))
      task_response = OpenStruct.new(task: '/pulp/api/v3/tasks/12345/')
      service_mock = mock('repository_service')
      service_mock.expects(:update_distribution).returns([task_response])
      Katello::Pulp3::Repository.stubs(:instance_for_type).returns(service_mock)
      task_mock = mock('task')
      task_mock.stubs(:done?).returns(true)
      task_mock.stubs(:error).returns(nil)
      Katello::Pulp3::Task.expects(:new).returns(task_mock)

      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([])

      assert_nothing_raised do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
    end

    def test_waits_for_distribution_tasks_to_complete
      python_repos = Katello::Repository.joins(:root).where(katello_root_repositories: { content_type: 'python' })
      repo = python_repos.first
      # Use update_column to set publication_href in database
      repo.update_column(:publication_href, '/pulp/api/v3/publications/python/pypi/old-pub/')
      repo.stubs(:environment).returns(mock('environment'))
      task_response = OpenStruct.new(task: '/pulp/api/v3/tasks/12345/')
      service_mock = mock('repository_service')
      service_mock.stubs(:update_distribution).returns([task_response])
      Katello::Pulp3::Repository.stubs(:instance_for_type).returns(service_mock)
      task_mock = mock('task')
      task_mock.stubs(:done?).returns(false).then.returns(true)
      task_mock.stubs(:poll).returns(task_mock)
      task_mock.stubs(:error).returns(nil)
      Katello::Pulp3::Task.expects(:new).returns(task_mock)

      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([])

      assert_nothing_raised do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def test_cleanup_handles_multiple_repos_with_multiple_publications
      # Verifies the following:
      # 1. Distribution updates are called for all 3 repos
      # 2. publication_href update_all is called (clearing all publication_hrefs)
      # 3. All 4 publications are deleted from Pulp

      repo1 = mock('repo1')
      repo1.stubs(:id).returns(1)
      repo1.stubs(:name).returns('Python Repo 1')
      repo1.stubs(:environment).returns(mock('environment1'))
      repo1.stubs(:publication_href).returns('/pulp/api/v3/publications/python/pypi/pub1/')

      repo2 = mock('repo2')
      repo2.stubs(:id).returns(2)
      repo2.stubs(:name).returns('Python Repo 2')
      repo2.stubs(:environment).returns(mock('environment2'))
      repo2.stubs(:publication_href).returns('/pulp/api/v3/publications/python/pypi/pub2/')

      repo3 = mock('repo3')
      repo3.stubs(:id).returns(3)
      repo3.stubs(:name).returns('Python Repo 3')
      repo3.stubs(:environment).returns(mock('environment3'))
      repo3.stubs(:publication_href).returns('/pulp/api/v3/publications/python/pypi/pub3/')

      python_repos_query = mock('python_repos_query')
      python_repos_query.stubs(:empty?).returns(false)
      python_repos_query.stubs(:select).returns([repo1, repo2, repo3])

      repos_with_pubs_relation = mock('repos_with_publications')
      repos_with_pubs_relation.stubs(:any?).returns(true)
      repos_with_pubs_relation.stubs(:count).returns(3)
      repos_with_pubs_relation.expects(:update_all).with(publication_href: nil).once

      where_relation = mock('where_relation')
      where_relation.stubs(:not).with(publication_href: nil).returns(repos_with_pubs_relation)
      python_repos_query.stubs(:where).returns(where_relation)
      join_relation = mock('join_relation')
      join_relation.stubs(:where).with(katello_root_repositories: { content_type: 'python' }).returns(python_repos_query)
      Katello::Repository.stubs(:joins).with(:root).returns(join_relation)

      task1_response = OpenStruct.new(task: '/pulp/api/v3/tasks/task1/')
      task2_response = OpenStruct.new(task: '/pulp/api/v3/tasks/task2/')
      task3_response = OpenStruct.new(task: '/pulp/api/v3/tasks/task3/')

      service_mock = mock('repository_service')
      service_mock.expects(:update_distribution).times(3).returns([task1_response], [task2_response], [task3_response])
      Katello::Pulp3::Repository.stubs(:instance_for_type).returns(service_mock)

      task_mock1 = mock('task1')
      task_mock1.stubs(:done?).returns(true)
      task_mock1.stubs(:error).returns(nil)
      task_mock2 = mock('task2')
      task_mock2.stubs(:done?).returns(true)
      task_mock2.stubs(:error).returns(nil)
      task_mock3 = mock('task3')
      task_mock3.stubs(:done?).returns(true)
      task_mock3.stubs(:error).returns(nil)
      Katello::Pulp3::Task.expects(:new).times(3).returns(task_mock1, task_mock2, task_mock3)

      pub1 = OpenStruct.new(pulp_href: '/pulp/api/v3/publications/python/pypi/pub1/')
      pub2 = OpenStruct.new(pulp_href: '/pulp/api/v3/publications/python/pypi/pub2/')
      pub3 = OpenStruct.new(pulp_href: '/pulp/api/v3/publications/python/pypi/pub3/')
      pub4 = OpenStruct.new(pulp_href: '/pulp/api/v3/publications/python/pypi/pub4/')

      publications_api_mock = mock('publications_api')
      # Verify each publication is deleted exactly once
      publications_api_mock.expects(:delete).with(pub1.pulp_href).once
      publications_api_mock.expects(:delete).with(pub2.pulp_href).once
      publications_api_mock.expects(:delete).with(pub3.pulp_href).once
      publications_api_mock.expects(:delete).with(pub4.pulp_href).once

      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([pub1, pub2, pub3, pub4])
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_api).returns(publications_api_mock)

      assert_nothing_raised do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def test_skips_repos_without_publication_href
      python_repos = Katello::Repository.joins(:root).where(katello_root_repositories: { content_type: 'python' })
      repo = python_repos.first
      repo.stubs(:environment).returns(mock('environment'))
      repo.update_column(:publication_href, nil)

      # Repository has environment but no publication_href, so it won't be selected for migration
      # No need to mock update_distribution since it won't be called
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([])

      assert_nothing_raised do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
    end

    def test_skips_when_no_python_repos_found
      empty_relation = Katello::Repository.where('1=0')
      join_relation = mock('join_relation')
      join_relation.stubs(:where).with(katello_root_repositories: { content_type: 'python' }).returns(empty_relation)
      Katello::Repository.stubs(:joins).with(:root).returns(join_relation)

      # SmartProxy.pulp_primary should not be called since we exit early
      SmartProxy.expects(:pulp_primary).never

      assert_nothing_raised do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
    end

    def test_errors_when_pulp_primary_not_found
      python_repos = Katello::Repository.joins(:root).where(katello_root_repositories: { content_type: 'python' })
      assert python_repos.any?, "Test requires at least one Python repository in fixtures"
      SmartProxy.stubs(:pulp_primary).returns(nil)

      exit_error = assert_raises(SystemExit) do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
      assert_equal 1, exit_error.status
    end

    def test_errors_when_distribution_task_fails
      python_repos = Katello::Repository.joins(:root).where(katello_root_repositories: { content_type: 'python' })
      repo = python_repos.first
      repo.update_column(:publication_href, '/pulp/api/v3/publications/python/pypi/old-pub/')
      repo.stubs(:environment).returns(mock('environment'))

      task_response = OpenStruct.new(task: '/pulp/api/v3/tasks/12345/')
      service_mock = mock('repository_service')
      service_mock.expects(:update_distribution).returns([task_response])
      Katello::Pulp3::Repository.stubs(:instance_for_type).returns(service_mock)
      task_mock = mock('task')
      task_mock.stubs(:done?).returns(true)
      task_mock.stubs(:error).returns("Distribution update failed")
      Katello::Pulp3::Task.expects(:new).returns(task_mock)

      exit_error = assert_raises(SystemExit) do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
      assert_equal 1, exit_error.status
    end
  end
end
