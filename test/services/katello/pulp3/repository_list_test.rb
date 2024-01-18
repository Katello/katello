require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class RepositoryListTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def sync_and_reload_repo(repo, smart_proxy)
          ForemanTasks.sync_task(
                    ::Actions::Pulp3::Orchestration::Repository::Update,
                    repo,
                    smart_proxy)

          sync_args = {:smart_proxy_id => smart_proxy.id, :repo_id => repo.id}
          ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::Repository::Sync,
            repo, smart_proxy, **sync_args)
        end

        def test_list_with_pagination
          User.current = users(:admin)
          @primary = SmartProxy.pulp_primary

          repo1 = katello_repositories(:generic_file)
          repo1.root.update(:url => 'https://fixtures.pulpproject.org/file-many/')
          create_repo(repo1, @primary)
          ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, repo1)
          sync_and_reload_repo(repo1, @primary)

          repo2 = katello_repositories(:pulp3_file_1)
          repo2.root.update(:url => 'https://repos.fedorapeople.org/pulp/pulp/demo_repos/test_file_repo/')
          create_repo(repo2, @primary)
          ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, repo2)
          sync_and_reload_repo(repo2, @primary)

          pulp3_enabled_repo_types = Katello::RepositoryTypeManager.enabled_repository_types.values.select do |repository_type|
            @primary.pulp3_repository_type_support?(repository_type)
          end

          repository_list = pulp3_enabled_repo_types.collect do |repo_type|
            repo_type.pulp3_api(@primary).list_all
          end

          Katello::Pulp3::RepositoryReference.all.each do |repo_reference|
            assert_includes repository_list.flatten.map(&:pulp_href), repo_reference.repository_href
          end
        end
      end
    end
  end
end
