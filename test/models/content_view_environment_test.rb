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
  class ContentViewEnvironmentTest < ActiveSupport::TestCase
    def self.before_suite
      #models = ["Organization", "KTEnvironment", "User", "ContentView",
      #          "ContentViewEnvironment", "ContentViewPuppetEnvironment", "ContentViewVersion"]
      #disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
    end

    def setup
      User.current = User.find(users(:admin))
      @system = Katello::System.find(katello_systems(:simple_server))
    end

    def test_for_systems
      cve = @system.content_view.content_view_environment(@system.environment)
      assert_include ContentViewEnvironment.for_systems(@system), cve
    end
  end
end
