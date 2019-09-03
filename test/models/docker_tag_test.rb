# encoding: utf-8

require 'katello_test_helper'

module Katello
  class DockerTagTest < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def setup
      @repo = Repository.find(katello_repositories(:busybox).id)
      @manifest = create(:docker_manifest)
      @tag = create(:docker_tag, :repositories => [@repo])

      @repo.clones.each do |repo|
        repo.docker_tags << @tag.dup
      end
    end

    def test_in_repositories
      tags = DockerTag.in_repositories(@repo)
      assert_equal [@tag], tags
    end

    def test_with_uuid
      @tag.update_attributes(:pulp_id => 'ksdjfkdjkfjdk')
      tag = DockerTag.with_pulp_id(@tag.pulp_id).first
      refute_nil tag
    end

    def test_related_tags
      assert_equal 4, @tag.related_tags.count
    end
  end
end
