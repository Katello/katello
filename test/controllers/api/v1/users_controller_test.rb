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
class Api::V1::UsersControllerTest < ActionController::TestCase
  def setup
    setup_engine_routes
  end

  def test_list_owners_username
    assert_routing "/api/users/admin@mail.com/owners", :controller => "katello/api/v1/users",
      :action => "list_owners", :login => "admin@mail.com"
  end
end
end
