require 'katello_test_helper'
require 'support/pulp3_support'
module Katello
  module Service
    module Pulp3
      class Repository
        class PythonTest < ActiveSupport::TestCase
          include Katello::Pulp3Support
          include RepositorySupport

          def setup
            @repo = katello_repositories(:pulp3_python_1)
            @primary = SmartProxy.pulp_primary

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
        end
      end
    end
  end
end
