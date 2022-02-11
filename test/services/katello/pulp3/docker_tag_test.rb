require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class DockerTagTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @primary = SmartProxy.pulp_primary
          @repo = katello_repositories(:pulp3_docker_1)
          ensure_creatable(@repo, @primary)
          create_repo(@repo, @primary)
          @repo.reload
        end

        def test_index_model
          Katello::DockerTag.destroy_all
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
          @repo.reload
          @repo.index_content
          assert_equal @repo, ::Katello::Repository.find_by(:id => ::Katello::RepositoryDockerTag.first.repository_id)
          assert_equal ::Katello::DockerManifest.find_by(id: ::Katello::DockerTag.first.docker_taggable_id).digest, "sha256:a6ecbb1553353a08936f50c275b010388ed1bd6d9d84743c7e8e7468e2acd82e"
        end

        def test_index_on_sync
          Katello::DockerTag.destroy_all
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload

          assert_equal @repo, ::Katello::Repository.find_by(:id => ::Katello::RepositoryDockerTag.first.repository_id)
          assert_equal ::Katello::DockerManifest.find_by(id: ::Katello::DockerTag.first.docker_taggable_id).digest, "sha256:a6ecbb1553353a08936f50c275b010388ed1bd6d9d84743c7e8e7468e2acd82e"
        end

        def test_resync_limit_tags_deletes_proper_repo_association_meta_tags
          # https://projects.theforeman.org/issues/34257
          Katello::DockerTag.destroy_all
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload

          meta_tag = @repo.docker_meta_tags.find_by(name: 'latest')
          dummy_cv_repo = ::Katello::Repository.find_by(pulp_id: 'Default_Organization-Test-busybox-dev')
          repo_meta_tag = ::Katello::RepositoryDockerMetaTag.create(docker_meta_tag_id: meta_tag.id, repository_id: dummy_cv_repo.id)

          @repo.root.update(:include_tags => ['doesntexist'])
          @repo.backend_service(SmartProxy.pulp_primary).refresh_if_needed
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload

          assert ::Katello::RepositoryDockerMetaTag.exists?(repo_meta_tag.id)
        end
      end
    end
  end
end
