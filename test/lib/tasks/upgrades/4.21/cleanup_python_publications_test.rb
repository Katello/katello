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

    def test_cleanup_with_no_publications
      # Mock the Pulp API to return empty list
      publications_api_mock = mock('publications_api')
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([])
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_api).returns(publications_api_mock)

      # Should complete successfully without errors
      assert_nothing_raised do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end
    end

    def test_cleanup_deletes_publications
      pub1 = OpenStruct.new(pulp_href: '/pulp/api/v3/publications/python/pypi/abc123/')
      pub2 = OpenStruct.new(pulp_href: '/pulp/api/v3/publications/python/pypi/def456/')
      publications_api_mock = mock('publications_api')
      publications_api_mock.expects(:delete).with(pub1.pulp_href).once
      publications_api_mock.expects(:delete).with(pub2.pulp_href).once
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([pub1, pub2])
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_api).returns(publications_api_mock)

      # Should delete both publications successfully
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
      publications_api_mock = mock('publications_api')
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).returns([])
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_api).returns(publications_api_mock)

      Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      assert_nil repo.reload.publication_href
    end

    def test_cleanup_handles_404_errors_gracefully
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
      # Mock the Pulp API to raise an error when listing publications
      error_message = "Connection to Pulp failed"
      Katello::Pulp3::Api::Core.any_instance.stubs(:publications_list_all).raises(StandardError.new(error_message))

      # Should exit with error status
      exit_error = assert_raises(SystemExit) do
        Rake.application.invoke_task('katello:upgrades:4.21:cleanup_python_publications')
      end

      assert_equal 1, exit_error.status
    end
  end
end
