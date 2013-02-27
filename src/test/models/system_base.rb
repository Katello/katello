#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'


class SystemTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures

  fixtures :all

  def self.before_suite
    load_fixtures
    configure_runcible

    services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
    models    = ['User', 'System', 'SystemGroup', 'KTEnvironment', 'Organization', 'Product']
    disable_glue_layers(services, models)
  end

  def setup
    @fedora             = Product.find(products(:fedora).id)
    @dev                = KTEnvironment.find(environments(:dev).id)
    @acme_corporation   = Organization.find(organizations(:acme_corporation).id)
    @system             = System.find(systems(:simple_server))
  end
end
