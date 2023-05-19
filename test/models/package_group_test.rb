require 'katello_test_helper'
require 'pry-byebug'

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
      assert_equal @repo.package_groups.sort, [@server_pg, @mammals_pg]
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

    def test_clean_filter_rules
      filter = FactoryBot.build(:katello_content_view_package_group_filter, :inclusion => true)
      server_rule = FactoryBot.create(:katello_content_view_package_group_filter_rule,
                                   :filter => filter,
                                   :uuid => @server_pg.pulp_id)
      mammals_rule = FactoryBot.create(:katello_content_view_package_group_filter_rule,
                                   :filter => filter,
                                   :uuid => @mammals_pg.pulp_id)
      content_type = Katello::RepositoryTypeManager.find_content_type('package_group')
      service_class = content_type.pulp3_service_class
      indexer = Katello::ContentUnitIndexer.new(content_type: content_type, repository: @repo)
      repo_associations = ::Katello::RepositoryPackageGroup.where(package_group_id: @mammals_pg.id, repository_id: @repo.id)
      filter.content_view.update(organization_id: @repo.organization.id)
      filter.content_view.repositories << @repo

      indexer.clean_filter_rules(repo_associations)
      server_rule.reload
      binding.pry
      assert_raises ActiveRecord::RecordNotFound do
        mammals_rule.reload
      end
    end
  end
end
