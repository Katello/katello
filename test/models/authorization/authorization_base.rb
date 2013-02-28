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


class AuthorizationTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures

  fixtures :all

  def self.before_suite
    services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
    models    = ['Repository', 'User', 'KTEnvironment', 'ContentViewEnvironment', 'Organization', 'System', 'SystemGroup']
    disable_glue_layers(services, models)
  end

  def setup
    Katello.config[:warden] = 'database'
    @no_perms_user      = User.find(users(:no_perms_user))
    @admin              = User.find(users(:admin))
    @disabled_user      = User.find(users(:disabled_user))

    @fedora_17_x86_64     = Repository.find(repositories(:fedora_17_x86_64).id)
    @fedora_17_x86_64_dev = Repository.find(repositories(:fedora_17_x86_64_dev).id)
    @fedora               = Product.find(products(:fedora).id)
    @library              = KTEnvironment.find(environments(:library).id)
    @dev                  = KTEnvironment.find(environments(:dev).id)
    @acme_corporation     = Organization.find(organizations(:acme_corporation).id)
    @unassigned_gpg_key   = GpgKey.find(gpg_keys(:unassigned_gpg_key).id)

    @system             = System.find(systems(:simple_server))
  end

end
