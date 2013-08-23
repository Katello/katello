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

require 'test_helper'

class AControllerTest < ActionController::TestCase
  ERROR_MESSAGE = 'user should not see this'

  class AController < ApplicationController
    def rules
      { failing_action: -> { true } }
    end

    def failing_action
      raise ERROR_MESSAGE
    end
  end

  self.controller_class = AController

  fixtures :all

  def setup
    @org = organizations :acme_corporation
    login_user users(:admin), @org

    Katello.config.stubs(hide_exceptions: true)
  end

  test 'any action test shows error notification for any error' do
    assert @controller.is_a? AController
    notify = stub exception: -> e, *_ { e.message == ERROR_MESSAGE }
    @controller.expects(:notify).returns(notify)
    get :failing_action
    assert response.body =~ /#{ERROR_MESSAGE}/
  end
end

