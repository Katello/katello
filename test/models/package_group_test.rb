require 'katello_test_helper'

module Katello
  class PackageGroupTest < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:fedora_17_x86_64)
      @server_pg = katello_package_groups(:server_pg)
      @mammals_pg = katello_package_groups(:mammals_pg)
      @filter = katello_content_view_filters(:populated_package_group_filter)
    end

    def test_repositories
      assert_includes @server_pg.repository_ids, @repo.id
      assert_equal @server_pg.repository, @repo
      assert_equal @repo.package_groups, [@server_pg, @mammals_pg]
    end

    def test_create
      pulp_id = "foo"
      assert PackageGroup.create!(:pulp_id => pulp_id)
      assert PackageGroup.find_by(:pulp_id => pulp_id)
    end

    def test_search_by_name
      assert_equal PackageGroup.search_for("name = mammals").first, @mammals_pg
    end

    def test_search_by_uuid
      assert_equal PackageGroup.search_for("id = #{@mammals_pg.pulp_id}").first, @mammals_pg
    end

    def test_search_returns_none
      assert_equal PackageGroup.search_for("name = fake"), []
    end

    def test_search_by_repository
      assert_includes PackageGroup.search_for('repository = "Fedora 17 x86_64"'), @mammals_pg
    end

    def test_in_content_view_filter
      assert @server_pg.in_content_view_filter?(@filter)
      refute @mammals_pg.in_content_view_filter?(@filter)
    end
  end
end
