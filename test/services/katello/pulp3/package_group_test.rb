require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class PackageGroupTestBase < ActiveSupport::TestCase
        include Pulp3Support

        def setup
          User.current = users(:admin)

          @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:fedora_17_x86_64)
          @repo.root.update(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo/')
          @repo.root.update(:download_policy => 'immediate')
          ensure_creatable(@repo, @primary)
          create_repo(@repo, @primary)
          ForemanTasks.sync_task(
              ::Actions::Katello::Repository::MetadataGenerate, @repo,
              repository_creation: true)
          @repo.reload
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
          @repo.reload
          Katello::PackageGroup.import_for_repository(@repo)
          @repo.reload

          @@package_groups = @repo.package_groups
          @@package_group_names = ['bird', 'mammal']
        end

        def teardown
          ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
          @repo.reload
        end
      end

      class PackageGroupVcrTest < PackageGroupTestBase
        def test_repo_package_groups
          assert_equal 2, @@package_groups.length
          assert_equal @@package_group_names, @@package_groups.map(&:name).sort
        end

        def test_pulp_data
          assert_equal @@package_group_names[0],
            ::Katello::Pulp3::PackageGroup.new(@@package_groups.min_by(&:name).pulp_id).backend_data["id"]
        end
      end

      class PackageGroupTest < ActiveSupport::TestCase
        def test_update_model_new
          uuid = 'foo'

          PackageGroup.where(:pulp_id => uuid).destroy_all
          group = PackageGroup.create!(:pulp_id => uuid)

          json = {'name' => 'foobar', 'pulp_href' => uuid}
          service = ::Katello::Pulp3::PackageGroup.new(uuid)
          service.backend_data = json
          service.update_model(group)

          assert_equal group.name, json["name"]
        end

        def test_update_from_json_desc
          pg = PackageGroup.create!(:pulp_id => "foo")
          json = pg.attributes.merge('description' => 'an update', 'pulp_href' => "foo").as_json
          service = ::Katello::Pulp3::PackageGroup.new(pg.pulp_id)
          service.backend_data = json
          service.update_model(pg)

          assert_equal pg.description, json['description']
        end
      end
    end
  end
end
