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


module TestUserBase
  def self.included(base)
    base.extend ClassMethods

    base.class_eval do
      set_fixture_class :environments => KTEnvironment
      use_instantiated_fixtures = false
      fixtures :all
    end
  end

  module ClassMethods
    def before_suite
      services  = ['Candlepin', 'Pulp', 'ElasticSearch']
      models    = ['User']
      disable_glue_layers(services, models)
    end
  end

  def setup
    AppConfig.warden = 'database'
    @no_perms_user  = User.find(users(:no_perms_user))
    @admin          = User.find(users(:admin))
    @disabled_user  = User.find(users(:disabled_user))
    @acme_corporation   = Organization.find(organizations(:acme_corporation).id)
    @dev                = KTEnvironment.find(environments(:dev).id)
  end

end



