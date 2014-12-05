
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
  class ContentViewVersionTest < ActiveSupport::TestCase
    def self.before_suite
      models = ["Organization", "KTEnvironment", "User", "ContentViewEnvironment",
                "Repository", "ContentView", "ContentViewVersion",
                "System", "ActivationKey"]
      services = ["Candlepin", "Pulp", "ElasticSearch"]
      disable_glue_layers(services, models, true)
    end

    def setup
      User.current = User.find(users(:admin))
      @cvv = create(:katello_content_view_version)
      @cvv.organization.kt_environments << Katello::KTEnvironment.find_by_name(:Library)
      @dev = create(:katello_environment,  :organization => @cvv.organization, :prior => @cvv.organization.library,     :name => 'dev')
      @beta = create(:katello_environment, :organization => @cvv.organization, :prior => @dev,                         :name => 'beta')
    end

    def test_promotable_in_sequence
      @cvv.expects(:environments).returns([@cvv.organization.library]).at_least_once
      assert @cvv.promotable?(@dev)
    end

    def test_promotable_out_of_sequence
      @cvv.expects(:environments).returns([@cvv.organization.library]).at_least_once
      refute @cvv.promotable?(@beta)
    end

    def test_promotoable_without_environments
      @cvv.expects(:environments).returns([]).at_least_once
      assert @cvv.promotable?(@cvv.organization.library)
    end

    def test_promotoable_without_environments2
      @cvv.expects(:environments).returns([]).at_least_once
      refute @cvv.promotable?(@dev)
    end

    def test_docker_count
      cv = katello_content_views(:library_view)
      cvv = cv.versions.first
      assert cvv.repositories.archived.docker_type.count > 0
      image_count = 0
      tag_count = 0
      cvv.repositories.archived.docker_type.each do |repo|
        image = repo.docker_images.create!({:image_id => "abc123", :katello_uuid => "123"},
                                             :without_protection => true
                                            )
        repo.docker_tags.create!(:tag => "wat", :image => image)
        image_count += repo.docker_images.count
        tag_count += repo.docker_tags.count
      end

      assert cvv.repositories.archived.docker_type.count > 0
      assert_equal image_count, cvv.docker_image_count
      assert_equal tag_count, cvv.docker_tag_count
    end
  end
end
