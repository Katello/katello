require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class DockerTagTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:pulp3_docker_1)
          ensure_creatable(@repo, @master)
          create_repo(@repo, @master)
          @repo.reload
        end

        def test_index_model
          Katello::DockerTag.destroy_all
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
          @repo.reload
          @repo.index_content
          assert_equal @repo, ::Katello::Repository.find_by(:id => ::Katello::RepositoryDockerTag.first.repository_id)
          assert_equal ::Katello::DockerManifest.find_by(id: ::Katello::DockerTag.first.docker_taggable_id).digest, "sha256:a6ecbb1553353a08936f50c275b010388ed1bd6d9d84743c7e8e7468e2acd82e"
        end

        def test_index_on_sync
          Katello::DockerTag.destroy_all
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload

          assert_equal @repo, ::Katello::Repository.find_by(:id => ::Katello::RepositoryDockerTag.first.repository_id)
          assert_equal ::Katello::DockerManifest.find_by(id: ::Katello::DockerTag.first.docker_taggable_id).digest, "sha256:a6ecbb1553353a08936f50c275b010388ed1bd6d9d84743c7e8e7468e2acd82e"
        end
      end
    end
  end
end
