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
      @images = YAML::load_file(IMAGES).values.map(&:symbolize_keys)
      @tags = YAML::load_file(TAGS).values.map(&:symbolize_keys)
      @repo_attrs = {:scratchpad => {:tags => @tags}}
    end

    def test_find
      id = @images.first[:_id]
      Runcible::Extensions::Repository.any_instance.stubs(:retrieve_with_details).
        with(REPO_ID).returns(@repo_attrs)
      Runcible::Extensions::DockerImage.any_instance.stubs(:find_by_unit_id).
        with(id).returns(@images.first)

      image = DockerImage.find(id)
      assert_equal id, image.id
      assert_empty image.tags

      image = DockerImage.find(id, REPO_ID)
      assert_equal ["latest"], image.tags
    end

    def test_find_all
      ids = @images.map { |attrs| attrs[:_id] }
      Runcible::Extensions::Repository.any_instance.stubs(:docker_image_ids).
        with(REPO_ID).returns(ids)
      Runcible::Extensions::DockerImage.any_instance.stubs(:find_all_by_unit_ids).
        with(ids).returns(@images)
      Runcible::Extensions::Repository.any_instance.stubs(:retrieve_with_details).
        with(REPO_ID).returns(@repo_attrs)

      images = DockerImage.find_all(REPO_ID)

      assert_equal 3, images.length
      assert_equal ["2.5.1", "1.2", "latest", "latest"].sort, images.flat_map(&:tags).sort
      assert_equal ["Default_Organization-Test-redis"], images.first.repoids
      assert_equal 42, images.last.size
    end

    def test_find_all_no_tags
      # test to make sure that even without a tags key, the code works
      ids = @images.map { |attrs| attrs[:_id] }
      Runcible::Extensions::Repository.any_instance.stubs(:docker_image_ids).
        with(REPO_ID).returns(ids)
      Runcible::Extensions::DockerImage.any_instance.stubs(:find_all_by_unit_ids).
        with(ids).returns(@images)
      Runcible::Extensions::Repository.any_instance.stubs(:retrieve_with_details).
        with(REPO_ID).returns({})

      images = DockerImage.find_all(REPO_ID)

      assert_equal 3, images.length
      assert_equal [], images.flat_map(&:tags).compact
      assert_equal ["Default_Organization-Test-redis"], images.last.repoids
    end

    def test_get_tags
      Runcible::Extensions::Repository.any_instance.stubs(:retrieve_with_details).
        with(REPO_ID).returns(@repo_attrs)
      tags = DockerImage.get_tags(REPO_ID, "2cffbad5f0fbc38ba7e82d1440042e57bfa5c89a41a5e99cd42bcd4968705f5d")
      assert_equal ["2.5.1", "1.2", "latest"], tags
    end
  end
end
