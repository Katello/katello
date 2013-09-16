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

require './test/minitest_helper'

module Pulp
  class UserSupport < MiniTest::Rails::ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    fixtures :users

    def self.hidden_user
      loaded_fixtures = load_fixtures
      id = loaded_fixtures['users']['hidden']['id']
      User.find(id)
    end

    def self.setup_hidden_user
      VCR.use_cassette('pulp/user/hidden') do
        user = hidden_user
        user.set_pulp_user({:password => user.password})
        user.set_super_user_role
      end
    end

    def self.delete_hidden_user
      VCR.use_cassette('pulp/user/hidden') do
        user = hidden_user
        user.del_pulp_user
      end
    end

  end
end
