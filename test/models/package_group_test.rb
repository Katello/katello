require 'katello_test_helper'

module Katello
  class PackageGroupTest < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:fedora_17_x86_64)
      @server_pg = katello_package_groups(:server_pg)
      @mammals_pg = katello_package_groups(:mammals_pg)
    end

    def test_repositories
      assert_includes @server_pg.repository_ids, @repo.id
      assert_equal @server_pg.repository, @repo
      assert_equal @repo.package_groups, [@server_pg, @mammals_pg]
    end

    def test_create
      uuid = "foo"
      assert PackageGroup.create!(:uuid => uuid)
      assert PackageGroup.find_by_uuid(uuid)
    end

    def test_update_from_json
      pg = PackageGroup.create!(:uuid => "foo")
      json = pg.attributes.merge('description' => 'an update')
      pg.update_from_json(json)
      assert_equal pg.description, json['description']
    end

    def test_search_by_name
      assert_equal PackageGroup.search_for("name = mammals").first, @mammals_pg
    end

    def test_search_by_uuid
      assert_equal PackageGroup.search_for("id = #{@mammals_pg.uuid}").first, @mammals_pg
    end

    def test_search_returns_none
      assert_equal PackageGroup.search_for("name = fake"), []
    end

    def test_search_by_repository
      assert_includes PackageGroup.search_for('repository = "Fedora 17 x86_64"'), @mammals_pg
    end
  end
end
