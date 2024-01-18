require 'katello_test_helper'
require 'support/pulp3_support'
module Katello
  module Service
    module Pulp3
      class Repository
        class PythonTest < ActiveSupport::TestCase
          include Katello::Pulp3Support

          def setup
            @repo = katello_repositories(:pulp3_python_1)
            @primary = SmartProxy.pulp_primary
            @repo.root.update(url: 'https://pypi.org')
            @repo.root.update(generic_remote_options: {includes: ['shelf-reader']}.to_json)

            create_repo(@repo, @primary)
            @repo.reload
          end

          def test_update
            ForemanTasks.sync_task(
              ::Actions::Pulp3::Repository::UpdateRepository, @repo, @primary)
          end

          def test_delete
            repo_reference = Katello::Pulp3::RepositoryReference.find_by(
              root_repository_id: @repo.root.id,
              content_view_id: @repo.content_view.id)

            refute_nil repo_reference

            ForemanTasks.sync_task(
              ::Actions::Pulp3::Repository::Delete, @repo.id, @primary)
            @repo.reload

            repo_reference = Katello::Pulp3::RepositoryReference.find_by(
              root_repository_id: @repo.root.id,
              content_view_id: @repo.content_view.id)

            assert_nil repo_reference
          end

          def test_index_on_sync
            Katello::GenericContentUnit.destroy_all
            sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
            ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
            index_args = {:id => @repo.id, :contents_changed => true}
            ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
            @repo.reload

            post_unit_count = Katello::GenericContentUnit.all.count
            post_unit_repository_count = Katello::RepositoryGenericContentUnit.where(:repository_id => @repo.id).count

            unit = @repo.generic_content_units.first

            assert_equal unit.content_type, "python_package"
            assert_includes unit.filename, "shelf_reader"
            refute unit.pulp_id.nil? && unit.version.nil?
            assert unit.additional_metadata['package_type'] && unit.additional_metadata['sha256']

            assert_equal post_unit_count, 2
            assert_equal post_unit_repository_count, 2
          end
        end
      end
    end
  end
end
