require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Services
    module Pulp3
      class SrpmTestBase < ActiveSupport::TestCase
        include Pulp3Support

        def setup
          User.current = users(:admin)

          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:fedora_17_x86_64)
          @repo.root.update_attributes(:url => 'https://repos.fedorapeople.org/pulp/pulp/fixtures/srpm/')
          ensure_creatable(@repo, @master)
          create_repo(@repo, @master)
          ForemanTasks.sync_task(
              ::Actions::Katello::Repository::MetadataGenerate, @repo,
              repository_creation: true)
          @repo.reload
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
          @repo.reload
          Katello::Srpm.import_for_repository(@repo)
          @repo.reload

          @@srpms = @repo.srpms
          @@srpm_names = ["test-srpm01", "test-srpm02", "test-srpm03"]
        end

        def teardown
          ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @master)
          @repo.reload
        end
      end

      class SrpmVcrTest < SrpmTestBase
        def test_repo_srpms
          assert_equal 3, @@srpms.length
          assert_equal @@srpm_names, @@srpms.map(&:name).sort
        end

        def test_pulp_data
          assert_equal @@srpm_names[0],
            ::Katello::Pulp3::Srpm.new(@@srpms.sort_by(&:name).first.pulp_id).backend_data["name"]
        end
      end

      class SrpmNonVcrTest < ActiveSupport::TestCase
        def test_update_model
          pulp_id = 'foo'
          model = Srpm.create!(:pulp_id => pulp_id)
          json = model.attributes.merge('pulp_href' => pulp_id, 'summary' => 'an update', 'version' => '3', 'release' => '4')

          service = Katello::Pulp3::Srpm.new(pulp_id)
          service.backend_data = json
          service.update_model(model)

          model = model.reload

          assert_equal model.summary, json['summary']
          refute model.release_sortable.blank?
          refute model.version_sortable.blank?
          refute model.nvra.blank?
        end
      end
    end
  end
end
