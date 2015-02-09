#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
  class DockerImageTest < ActiveSupport::TestCase
    REPO_ID = "Default_Organization-Test-redis"
    IMAGES = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "docker_images.yml")
    TAGS = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "docker_tags.yml")

    def setup
      @images = YAML.load_file(IMAGES).values.map(&:symbolize_keys)
      @tags = YAML.load_file(TAGS).values.map(&:symbolize_keys)
      @repo_attrs = {:scratchpad => {:tags => @tags}}
      @repo = Repository.find(katello_repositories(:redis))

      ids = @images.map { |attrs| attrs[:_id] }
      Runcible::Extensions::Repository.any_instance.stubs(:docker_image_ids).
        with(REPO_ID).returns(ids)
      Runcible::Extensions::DockerImage.any_instance.stubs(:find_all_by_unit_ids).
        with(ids).returns(@images)
      Runcible::Extensions::Repository.any_instance.stubs(:retrieve_with_details).
        with(REPO_ID).returns(@repo_attrs)
    end

    def test_index_db_docker_images
      @repo.index_db_docker_images
      assert_equal 3, DockerImage.count
      assert_equal 3, @repo.docker_images.count
      assert_equal [0, 0, 42], DockerImage.all.map(&:size).sort

      image = DockerImage.find_by_image_id("2cffbad5f0fbc38ba7e82d1440042e57bfa5c89a41a5e99cd42bcd4968705f5d")
      tags = image.docker_tags.map(&:name).sort
      assert_equal ["1.2", "2.5.1", "latest"], tags
    end

    def test_index_db_docker_images_with_duplicate_tags
      @repo.docker_images.create!(:image_id => "abc123")
      docker_image = @repo.docker_images.first
      @repo.docker_tags.create!(:docker_image => docker_image,
                                :name => "latest"
                               )

      @repo.index_db_docker_images
      assert_equal 4, @repo.docker_tags.reload.length
      image = DockerImage.find_by_image_id("2cffbad5f0fbc38ba7e82d1440042e57bfa5c89a41a5e99cd42bcd4968705f5d")
      assert_equal 1, @repo.docker_tags.where(:name => "latest").count
      refute_nil @repo.docker_tags.where(:docker_image_id => image.id, :name => "latest").first
    end
  end
end
