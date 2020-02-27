require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Service
    class PackageGroupTestBase < ActiveSupport::TestCase
      include RepositorySupport

      def setup
        User.current = users(:admin)

        @repo = katello_repositories(:fedora_17_x86_64)
        RepositorySupport.create_and_sync_repo(@repo)
        Katello::PackageGroup.import_for_repository(@repo)

        @@package_groups = @repo.package_groups
        @@package_group_names = ['bird', 'mammal']
      end

      def teardown
        RepositorySupport.destroy_repo(@repo)
      end
    end

    class PackageGroupVcrTest < PackageGroupTestBase
      def test_repo_package_groups
        assert_equal 2, @@package_groups.length
        assert_equal @@package_group_names, @@package_groups.map(&:name).sort
      end

      def test_pulp_data
        assert_equal @@package_group_names[0], Pulp::PackageGroup.pulp_data(@@package_groups.min_by(&:name).pulp_id)['id']
      end
    end

    class PackageGroupTest < ActiveSupport::TestCase
      def test_update_model_new
        uuid = 'foo'

        PackageGroup.where(:pulp_id => uuid).destroy_all
        group = PackageGroup.create!(:pulp_id => uuid)

        json = {'name' => 'foobar'}
        service = Pulp::PackageGroup.new(uuid)
        service.backend_data = json
        service.update_model(group)

        assert_equal group.name, json["name"]
      end

      def test_update_from_json_desc
        pg = PackageGroup.create!(:pulp_id => "foo")
        json = pg.attributes.merge('description' => 'an update').as_json
        service = Pulp::PackageGroup.new(pg.pulp_id)
        service.backend_data = json
        service.update_model(pg)

        assert_equal pg.description, json['description']
      end
    end
  end
end
