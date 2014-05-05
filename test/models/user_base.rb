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
class UserTestBase < ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures

  def self.before_suite
    configure_runcible

    services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
    models    = ['User', 'System', 'LifecycleEnvironment', 'Repository', 'Organization']
    disable_glue_layers(services, models)
    super
  end

  def setup
    @no_perms_user      = User.find(users(:one))
    @admin              = User.find(users(:admin))
    @acme_corporation   = get_organization

    @dev                = LifecycleEnvironment.find(katello_environments(:dev).id)
  end

end
end
