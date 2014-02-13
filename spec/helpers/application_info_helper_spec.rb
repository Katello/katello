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

def current_user
  User.current
end

module Katello
describe ApplicationInfoHelper do
  include AuthorizationHelperMethods
  helper ApplicationInfoHelper

  context '.can_read_system_info?' do
    before(:each) do
      Resources::Candlepin::Owner.stubs(:create_user).returns(true)
      Resources::Candlepin::Owner.expects(:create).once.returns({})
      disable_env_orchestration
      disable_user_orchestration
      Katello.config[:warden] = 'ldap'
      Katello.config[:validate_ldap] = false
      User.stubs(:cp_oauth_header).returns("abc123")

      as_admin do
        @org = Organization.create!(:name => "Haskell_Curry_Inc",
                                    :label => "haskell_curry_inc"
                                   )
      end
      @user = users(:one)
    end

    it 'should return false if there is no current user' do
      User.current = nil
      can_read_system_info?.must_equal(false)
    end

    it 'should return false for a user without org read access' do
      User.current = @user
      can_read_system_info?.must_equal(false)
    end

    it 'should return true for a user with org read access' do
      User.current = @user
      allow(@user.own_role, [:read], :organizations, nil, @org)
      can_read_system_info?.must_equal(true)
    end
  end
end
end
