# encoding: utf-8

require 'katello_test_helper'

module Katello
  class DockerMetaTagTest < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def setup
      @repo = Repository.find(katello_repositories(:busybox).id)
      @tag_schema2 = create(:docker_tag, :with_manifest_list, :repositories => [@repo], :name => "latest")
      @tag_schema1 = create(:docker_tag, :schema1, :repositories => [@repo], :name => "latest")

      @repo.library_instances_inverse.each do |repo|
        repo.docker_tags << @tag_schema2.dup
        repo.docker_tags << @tag_schema1.dup
      end
    end

    def test_complete_for
      refute_nil DockerMetaTag.complete_for("repository=")
      refute_nil DockerMetaTag.search_for("repository='foo'")
    end

    def test_related_tags
      assert_equal 8, @tag_schema1.related_tags.count
      assert_equal 8, @tag_schema2.related_tags.count
    end

    def test_with_uuid
      meta_one = DockerMetaTag.create!(:name => @tag_schema1.name, :schema1 => @tag_schema1, :repositories => [@repo])
      DockerMetaTag.create!(:name => @tag_schema2.name, :schema2 => @tag_schema2, :repositories => [@repo])

      result = DockerMetaTag.with_pulp_id(meta_one.id)

      assert_includes result, meta_one
      assert_equal 1, result.length
    end

    def test_import_meta_tags
      assert_empty DockerMetaTag.where(:schema1 => [@tag_schema1.id, @tag_schema2.id])
      assert_empty DockerMetaTag.where(:schema2 => [@tag_schema1.id, @tag_schema2.id])

      DockerMetaTag.import_meta_tags([@repo])

      assert_equal 1, DockerMetaTag.where(:schema1 => @tag_schema1.id).count
      assert_equal 1, DockerMetaTag.where(:schema2 => @tag_schema2.id).count

      meta = DockerMetaTag.find_by(:schema1 => @tag_schema1.id)
      assert_equal @tag_schema2, meta.schema2
      assert_equal @repo, meta.repositories.first

      RepositoryDockerTag.where(:docker_tag_id => @tag_schema1.id).delete_all
      DockerTag.where(:id => @tag_schema1.id).delete_all
      DockerMetaTag.where(:schema1 => @tag_schema1.id).destroy_all
      DockerMetaTag.import_meta_tags([@repo])

      assert_empty DockerMetaTag.where(:schema1 => @tag_schema1.id)
      assert_equal 1, DockerMetaTag.where(:schema2 => @tag_schema2.id).count

      @tag_schema1 = create(:docker_tag, :schema1, :repositories => [@repo], :name => "latest")
      DockerMetaTag.import_meta_tags([@repo])
      old_meta = meta

      meta = DockerMetaTag.find_by(:schema1 => @tag_schema1.id)
      assert_equal @tag_schema2, meta.schema2
      assert_equal @repo, meta.repositories.first

      refute_equal old_meta.id, meta.id

      @tag_schema1.destroy!
      meta = meta.reload
      assert_nil meta.schema1
    end

    def test_in_repositories
      DockerMetaTag.import_meta_tags([@repo])
      tags = DockerMetaTag.in_repositories(@repo)
      assert_equal @tag_schema1.repositories.first, tags.first.repositories.first
      assert_equal 1, tags.count

      new_tag = create(:docker_tag, :schema1, :repositories => [@repo])
      DockerMetaTag.import_meta_tags([@repo])

      tags = DockerMetaTag.in_repositories(@repo, true).pluck(:name)
      assert_equal tags, DockerMetaTag.where(:name => ["latest", new_tag.name]).pluck(:name)
    end

    def test_docker_manifest
      DockerMetaTag.import_meta_tags([@repo])
      dmt = DockerMetaTag.first
      assert_equal @tag_schema2.docker_manifest, dmt.docker_manifest

      dmt.schema2 = nil
      assert_equal @tag_schema1.docker_manifest, dmt.docker_manifest
    end

    def test_delete_docker_meta_tag
      DockerMetaTag.import_meta_tags([@repo])
      assert_equal 1, DockerMetaTag.where(:schema1 => @tag_schema1.id).count
      assert_equal 1, DockerMetaTag.where(:schema2 => @tag_schema2.id).count
      dmt = DockerMetaTag.first
      dmt.schema1.destroy
      assert_equal 0, DockerMetaTag.where(:schema1 => @tag_schema1.id).count
      dmt.schema2.destroy
      assert_equal 0, DockerMetaTag.where(:schema2 => @tag_schema2.id).count

      assert_equal 0, DockerMetaTag.where(:id => dmt.id).count
    end

    def test_docker_tag_associated_meta_tag
      DockerMetaTag.import_meta_tags([@repo])
      dmt = DockerMetaTag.first
      assert_equal dmt, dmt.schema1.associated_meta_tag
      assert_equal dmt.schema1.schema1_meta_tag, dmt.schema1.associated_meta_tag
      assert_equal dmt.id, dmt.schema1.associated_meta_tag_identifier

      assert_equal dmt, dmt.schema2.associated_meta_tag
      assert_equal dmt.schema2.schema2_meta_tag, dmt.schema2.associated_meta_tag
      assert_equal dmt.id, dmt.schema2.associated_meta_tag_identifier
    end

    def test_search_meta_tag
      DockerMetaTag.import_meta_tags([@repo])
      dmt = DockerMetaTag.first
      assert_includes DockerMetaTag.search_for("schema_version = 2"), dmt
      assert_includes DockerMetaTag.search_for("schema_version = 1"), dmt
      refute_includes DockerMetaTag.search_for("schema_version = 3"), dmt

      assert_includes DockerMetaTag.search_for("tag = #{dmt.name}"), dmt
      refute_includes DockerMetaTag.search_for("tag = #{dmt.name}00009s"), dmt

      assert_includes DockerMetaTag.search_for("repository = #{dmt.repositories.first.name}"), dmt
    end

    def test_search_in_tags
      DockerMetaTag.import_meta_tags([@repo])
      repo2 = Repository.find_by(pulp_id: "Default_Organization-Test-busybox-dev")
      dup_tag = DockerMetaTag.create(schema1_id: repo2.docker_tags.sort.first.id, schema2_id: repo2.docker_tags.sort.second.id, name: "latest")
      RepositoryDockerMetaTag.create(docker_meta_tag_id: dup_tag.id, repository_id: repo2.id)

      assert_equal DockerMetaTag.search_in_tags(DockerTag.all).sort, [DockerMetaTag.first, dup_tag]
      assert_equal DockerMetaTag.search_in_tags(DockerTag.all, true).sort, [DockerMetaTag.first]
    end
  end
end
