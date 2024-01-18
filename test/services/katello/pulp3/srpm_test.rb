require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Services
    module Pulp3
      class SrpmTestBase < ActiveSupport::TestCase
        include Pulp3Support

        def setup
          User.current = users(:admin)

          @primary = SmartProxy.pulp_primary
          @repo = katello_repositories(:fedora_17_x86_64)
          @repo.root.update(:url => 'https://fixtures.pulpproject.org/srpm-signed/')
          ensure_creatable(@repo, @primary)
          create_repo(@repo, @primary)
          ForemanTasks.sync_task(
              ::Actions::Katello::Repository::MetadataGenerate, @repo)
          @repo.reload
        end

        def teardown
          ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
          @repo.reload
        end
      end

      class SrpmVcrTest < SrpmTestBase
        def setup
          super
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
          @repo.reload
          Katello::Srpm.import_for_repository(@repo)
          @repo.reload

          @@srpms = @repo.srpms
          @@srpm_names = ["test-srpm01", "test-srpm02", "test-srpm03"]
        end

        def test_repo_srpms
          assert_equal 3, @@srpms.length
          assert_equal @@srpm_names, @@srpms.map(&:name).sort
        end

        def test_pulp_data
          assert_equal @@srpm_names[0],
            ::Katello::Pulp3::Srpm.new(@@srpms.min_by(&:name).pulp_id).backend_data["name"]
        end
      end

      class SrpmVcrInitialSyncTest < SrpmTestBase
        def test_sync_skipped_srpm
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          @repo.root.update!(ignorable_content: ["srpm"])
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
          @repo.reload
          Katello::Srpm.import_for_repository(@repo)
          @repo.reload
          total_repository_srpms = Katello::RepositorySrpm.where(repository_id: @repo.id).count
          assert_equal total_repository_srpms, 0
        end

        def test_sync_skipped_treeinfo
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          @repo.root.update!(ignorable_content: ["treeinfo"])
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
        end
      end

      class SrpmNonVcrTest < ActiveSupport::TestCase
        def test_generate_model_row
          pulp_id = 'foo'
          model = Srpm.create!(:pulp_id => pulp_id)
          json = model.attributes.merge('pulp_href' => pulp_id, 'summary' => 'an update', 'version' => '3', 'release' => '4')

          row = Katello::Pulp3::Srpm.generate_model_row(json)
          model = ::Katello::Srpm.new(row)

          assert_equal model.summary, json['summary']
          refute model.release_sortable.blank?
          refute model.version_sortable.blank?
          refute model.nvra.blank?
        end
      end
    end
  end
end
