require 'katello_test_helper'

module Katello
  class ContentViewDockerFilterTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @rule = FactoryBot.build(:katello_content_view_docker_filter_rule)
    end

    def test_repo_clause
      repo = Repository.find(katello_repositories(:busybox).id)
      schema2 = create(:docker_tag, :with_uuid, :repository => repo, :name => "latest")
      schema1 = create(:docker_tag, :with_uuid, :schema1, :repository => repo, :name => "latest")

      repo.docker_tags << schema2
      repo.docker_tags << schema1
      repo.docker_manifests << schema1.docker_manifest
      repo.docker_manifests << schema2.docker_manifest

      repo.save!
      DockerMetaTag.import_meta_tags([repo])

      @rule.name = "latest"
      @rule.save!

      filter = FactoryBot.build(:katello_content_view_docker_filter, :docker_rules => [@rule])
      clauses = filter.generate_clauses(repo)
      refute_empty clauses
      refute_empty clauses["_id"]
      refute_empty clauses["_id"]["$in"]
      assert_equal 2, clauses["_id"]["$in"].size
      assert_includes clauses["_id"]["$in"], schema1.uuid
      assert_includes clauses["_id"]["$in"], schema2.uuid
    end

    def test_repo_clause_with_manifest_lists
      repo = Repository.find(katello_repositories(:busybox).id)
      schema2 = create(:docker_tag, :with_uuid, :with_manifest_list, :repository => repo, :name => "latest")
      schema1 = create(:docker_tag, :with_uuid, :with_manifest_list, :schema1, :repository => repo, :name => "latest")

      repo.docker_tags << schema2
      repo.docker_tags << schema1
      repo.docker_manifest_lists << schema1.docker_manifest_list
      repo.docker_manifest_lists << schema2.docker_manifest_list

      repo.save!
      DockerMetaTag.import_meta_tags([repo])

      @rule.name = "latest"
      @rule.save!

      filter = FactoryBot.build(:katello_content_view_docker_filter, :docker_rules => [@rule])
      clauses = filter.generate_clauses(repo)
      refute_empty clauses
      refute_empty clauses["_id"]
      refute_empty clauses["_id"]["$in"]
      assert_equal 2, clauses["_id"]["$in"].size
      assert_includes clauses["_id"]["$in"], schema1.uuid
      assert_includes clauses["_id"]["$in"], schema2.uuid
    end

    # rubocop:disable MethodLength
    def test_repo_intersection_clause
      #create repo1 with tag goo
      repo1 = Repository.find(katello_repositories(:busybox).id)
      schema1_repo1 = create(:docker_tag, :with_uuid, :repository => repo1, :name => "latest")
      schema2_repo1 = create(:docker_tag, :with_uuid, :schema1, :repository => repo1, :name => "latest")

      # Create a docker tag goo that points to the same manifest as schema1_repo1
      # i.e. both latest and goo point ot the same manifest
      schema_goo_repo1 = create(:docker_tag, :with_uuid, :repository => repo1, :name => "goo")
      schema_goo_repo1.docker_taggable = schema1_repo1.docker_manifest
      schema_goo_repo1.save!

      repo1.docker_tags << schema2_repo1
      repo1.docker_tags << schema1_repo1
      repo1.docker_tags << schema_goo_repo1

      repo1.docker_manifests << schema1_repo1.docker_manifest
      repo1.docker_manifests << schema2_repo1.docker_manifest
      repo1.save!

      DockerMetaTag.import_meta_tags([repo1])

      # now setup repo2
      # same manifests
      # but different tagW as in No goo
      repo2 = Repository.find(katello_repositories(:busybox2).id)
      schema1_repo2 = create(:docker_tag, :with_uuid, :repository => repo1, :name => "latest")
      schema2_repo2 = create(:docker_tag, :with_uuid, :schema1, :repository => repo1, :name => "latest")

      schema1_repo2.docker_taggable = schema1_repo1.docker_manifest
      schema2_repo2.docker_taggable = schema2_repo1.docker_manifest
      schema1_repo2.save!
      schema2_repo2.save!

      repo2.docker_tags << schema1_repo2
      repo2.docker_tags << schema2_repo2

      repo2.docker_manifests << schema1_repo2.docker_manifest
      repo2.docker_manifests << schema2_repo2.docker_manifest
      repo2.save!
      DockerMetaTag.import_meta_tags([repo2])

      # search for goo in repo1
      # should be a success
      @rule.name = "goo"
      @rule.save!

      filter = FactoryBot.build(:katello_content_view_docker_filter, :docker_rules => [@rule])
      clauses = filter.generate_clauses(repo1)

      refute_empty clauses
      assert_equal 2, clauses["_id"]["$in"].size
      assert_includes clauses["_id"]["$in"], schema_goo_repo1.uuid
      assert_includes clauses["_id"]["$in"], schema1_repo1.uuid

      # now search for goo in repo2
      # it should be nil
      assert_nil filter.generate_clauses(repo2)
    end
  end
end
