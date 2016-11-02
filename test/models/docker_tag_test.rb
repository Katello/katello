# encoding: utf-8

require 'katello_test_helper'

module Katello
  class DockerTagTest < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def setup
      @repo = Repository.find(katello_repositories(:busybox).id)
      @manifest = create(:docker_manifest)
      @tag = create(:docker_tag, :repository => @repo)

      @repo.library_instances_inverse.each do |repo|
        repo.docker_tags << @tag.dup
      end
    end

    def test_import_from_json
      @tag.repository_id = nil
      @tag.docker_manifest_id = nil
      @tag.name = nil
      @tag.save!

      json = {'manifest_digest' => @manifest.digest, 'repo_id' => @repo.pulp_id, 'name' => 'jabberwock'}
      @tag.update_from_json(json)

      refute_nil @tag.name
      assert_equal @tag.docker_manifest, @manifest
    end

    def test_in_repositories
      tags = DockerTag.in_repositories(@repo)
      assert_equal [@tag], tags
    end

    def test_with_uuid
      tag = DockerTag.with_uuid(@tag.uuid).first
      refute_nil tag
    end

    def test_grouped
      assert_equal 1, DockerTag.grouped.where(:name => @tag.name).count

      create(:docker_tag, :latest, :repository => @repo)
      assert_equal 2, DockerTag.grouped.where(:name => [@tag.name, "latest"]).count
    end

    def test_related_tags
      assert_equal 3, @tag.related_tags.count
    end

    def test_full_name
      assert_equal "#{@tag.docker_manifest.name}:#{@tag.name}", @tag.full_name
    end
  end
end
