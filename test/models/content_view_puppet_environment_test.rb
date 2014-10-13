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
  class ContentViewPuppetEnvironmentTest < ActiveSupport::TestCase

    def self.before_suite
      models = ["Organization", "KTEnvironment", "User", "ContentView",
                "ContentViewEnvironment", "ContentViewPuppetEnvironment", "ContentViewVersion"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
    end

    def setup
      User.current = User.find(users(:admin))

      @library = FactoryGirl.build(:katello_environment, :library => true)
      @content_view_version = FactoryGirl.build(:katello_content_view_version)

      @puppet_env = FactoryGirl.build(:katello_content_view_puppet_environment,
                                      :library_content_view_puppet_environment,
                                      :environment => @library,
                                      :content_view_version => @content_view_version)
    end

    def test_create
      assert @puppet_env.save
      refute_empty ContentViewPuppetEnvironment.where(:id => @puppet_env.id)
    end

    def test_content_type
      assert @puppet_env.save
      assert_equal "puppet", ContentViewPuppetEnvironment.find(@puppet_env.id).content_type
    end

    def test_in_content_view
      assert @puppet_env.save
      refute_empty ContentViewPuppetEnvironment.in_content_view(@content_view_version.content_view)

      library_dev_view = ContentView.find(katello_content_views(:library_dev_view))
      assert_empty ContentViewPuppetEnvironment.in_content_view(library_dev_view)
    end

    def test_in_environment
      assert @puppet_env.save
      refute_empty ContentViewPuppetEnvironment.in_environment(@library)

      dev = KTEnvironment.find(katello_environments(:staging).id)
      assert_empty ContentViewPuppetEnvironment.in_environment(dev)
    end

    def test_archive
      refute @puppet_env.archive?

      @puppet_env.environment = nil
      @puppet_env.save
      assert @puppet_env.archive?
    end

    def test_generate_pulp_id
      assert_equal ContentViewPuppetEnvironment.generate_pulp_id("org", "env", "view", "version"),
                   "org-env-view-version"

      assert_equal ContentViewPuppetEnvironment.generate_pulp_id("org", "env", "view", nil),
                   "org-env-view"

      assert_equal ContentViewPuppetEnvironment.generate_pulp_id("org", nil, "view", "version"),
                   "org-view-version"
    end
  end
end
