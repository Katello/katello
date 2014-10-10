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
  class Api::Rhsm::CandlepinProxiesControllerTest < ActionController::TestCase

    def setup
      setup_controller_defaults
      @proxies_controller = "katello/api/rhsm/candlepin_proxies"
    end

    def test_user_resource_proxies
      {:controller => @proxies_controller, :action => "list_owners", :login => "1"}.must_recognize(:method => "get", :path => "/rhsm/users/1/owners")
    end

  end
end
