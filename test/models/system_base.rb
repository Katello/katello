#
# Copyright 2013 Red Hat, Inc.
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
  class SystemTestBase < ActiveSupport::TestCase

    def self.before_suite
      services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
      models    = ['User', 'SystemGroup', 'KTEnvironment', 'Organization', 'Product', "ContentView", "System", "ContentViewVersion"]
      disable_glue_layers(services, models)

      configure_runcible
    end

    def setup
      @acme_corporation   = get_organization(:organization1)

      @fedora             = Product.find(katello_products(:fedora).id)
      @dev                = KTEnvironment.find(katello_environments(:dev).id)
      @system             = System.find(katello_systems(:simple_server))
    end
  end
end
