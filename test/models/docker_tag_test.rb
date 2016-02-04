# encoding: utf-8

require 'katello_test_helper'

module Katello
  class DockerTagTest < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def setup
      @repo = Repository.find(katello_repositories(:busybox))
      @tag = create(:docker_tag, :repository => @repo)

      @repo.library_instances_inverse.each do |repo|
        repo.docker_tags << @tag.dup
      end
    end

    def test_in_repositories
      tags = DockerTag.in_repositories(@repo)
      assert_equal [@tag], tags
    end

    def test_with_uuid
      tag = DockerTag.with_uuid(@tag.id).first
      refute_nil tag
      assert_equal @tag.id, tag.id
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
      assert_equal "busybox:#{@tag.name}", @tag.full_name
    end
  end
end
