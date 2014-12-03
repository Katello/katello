# encoding: UTF-8
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
  class EnvironmentExtensionsTest < ActiveSupport::TestCase
    def self.before_suite
      models = ["Organization", "ContentView", "User"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
    end

    def setup
      User.current = User.find(users(:admin))
      @katello_id = "KT_Org_Env_View_1"

      @org = get_organization
      @org.label = @org.label.gsub(' ', '_')
      @env = KTEnvironment.find(katello_environments(:dev))
      @content_view = ContentView.find(katello_content_views(:library_dev_view))
    end

    def test_construct_katello_id
      id = Environment.construct_katello_id(@org, @env, @content_view)
      assert_equal id, [@org.label, @env.label, @content_view.label].join('/')
    end

    def test_construct_name
      name = Environment.construct_name(@org, @env, @content_view)
      assert_equal name, ["KT", @org.label, @env.label, @content_view.label, @content_view.id].join('_')
    end

    def test_create_by_katello_id
      refute_nil Environment.create_by_katello_id(@org, @env, @content_view)
    end

    def test_find_by_katello_id
      assert_nil Environment.find_by_katello_id(@org, @env, @content_view)

      Environment.create_by_katello_id(@org, @env, @content_view)

      refute_nil Environment.find_by_katello_id(@org, @env, @content_view)
    end

    def test_find_or_create_by_katello_id
      assert_nil Environment.find_by_katello_id(@org, @env, @content_view)
      refute_nil Environment.find_or_create_by_katello_id(@org, @env, @content_view)
    end
  end
end
