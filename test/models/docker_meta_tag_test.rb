# encoding: utf-8

require 'katello_test_helper'

module Katello
  class DockerMetaTagTest < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def setup
      @repo = Repository.find(katello_repositories(:busybox).id)
      @manifest = create(:docker_manifest)
      @tag_schema2 = create(:docker_tag, :repository => @repo, :name => "latest")
      @tag_schema1 = create(:docker_tag, :schema1, :repository => @repo, :name => "latest")

      @repo.library_instances_inverse.each do |repo|
        repo.docker_tags << @tag_schema2.dup
        repo.docker_tags << @tag_schema1.dup
      end
    end

    def test_import_meta_tags
      assert_empty DockerMetaTag.where(:schema1 => [@tag_schema1.id, @tag_schema2.id])
      assert_empty DockerMetaTag.where(:schema2 => [@tag_schema1.id, @tag_schema2.id])

      DockerMetaTag.import_meta_tags([@repo])

      assert_equal 1, DockerMetaTag.where(:schema1 => @tag_schema1.id).count
      assert_equal 1, DockerMetaTag.where(:schema2 => @tag_schema2.id).count

      meta = DockerMetaTag.find_by(:schema1 => @tag_schema1.id)
      assert_equal @tag_schema2, meta.schema2
      assert_equal @repo, meta.repository

      DockerTag.where(:id => @tag_schema1.id).delete_all
      DockerMetaTag.import_meta_tags([@repo])
      assert_empty DockerMetaTag.where(:schema1 => @tag_schema1.id)
      assert_equal 1, DockerMetaTag.where(:schema2 => @tag_schema2.id).count

      @tag_schema1 = create(:docker_tag, :schema1, :repository => @repo, :name => "latest")
      DockerMetaTag.import_meta_tags([@repo])
      old_meta = meta

      meta = DockerMetaTag.find_by(:schema1 => @tag_schema1.id)
      assert_equal @tag_schema2, meta.schema2
      assert_equal @repo, meta.repository

      refute_equal old_meta.id, meta.id

      @tag_schema1.destroy!
      meta = meta.reload
      assert_nil meta.schema1
    end

    def test_in_repositories
      DockerMetaTag.import_meta_tags([@repo])
      tags = DockerMetaTag.in_repositories(@repo)
      assert_equal @tag_schema1.repository, tags.first.repository
      assert_equal 1, tags.count

      new_tag = create(:docker_tag, :schema1, :repository => @repo)
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
  end
end
