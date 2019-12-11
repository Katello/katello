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
            repo, smart_proxy, sync_args)
        end

        def test_list_with_pagination
          User.current = users(:admin)
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)

          repo1 = katello_repositories(:pulp3_file_1)
          repo1.root.update_attributes(:url => 'https://repos.fedorapeople.org/repos/pulp/pulp/fixtures/file-many/')
          ensure_creatable(repo1, @master)
          create_repo(repo1, @master)
          ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, repo1)
          sync_and_reload_repo(repo1, @master)

          repo2 = katello_repositories(:pulp3_file_1)
          repo2.root.update_attributes(:url => 'https://repos.fedorapeople.org/pulp/pulp/demo_repos/test_file_repo/')
          ensure_creatable(repo2, @master)
          create_repo(repo2, @master)
          ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, repo2)
          sync_and_reload_repo(repo2, @master)

          pulp3_enabled_repo_types = Katello::RepositoryTypeManager.repository_types.values.select do |repository_type|
            @master.pulp3_repository_type_support?(repository_type)
          end

          repository_list = pulp3_enabled_repo_types.collect do |repo_type|
            repo_type.pulp3_service_class.api(@master).list_all
          end

          Katello::Pulp3::RepositoryReference.all.each do |repo_reference|
            assert_includes repository_list.flatten.map(&:pulp_href), repo_reference.repository_href
          end
        end
      end
    end
  end
end
