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
  class AutoCompleteSearchControllerTest < ActionController::TestCase

    def setup
      setup_controller_defaults
      login_user(User.find(users(:admin)))
      models
      permissions
    end

    def test_auto_complete_search
      @request.env['HTTP_ACCEPT'] = 'application/json'
      Katello::System.expects(:complete_for).returns([" name =  \"Simple Server 3\""])

      get :auto_complete_search, :search => " name = Simpl*3", :kt_path => 'content_hosts'

      assert_response :success
    end
  end
end
