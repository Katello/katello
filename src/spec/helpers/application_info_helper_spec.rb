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

require 'spec_helper'

def current_user
  User.current
end

describe ApplicationInfoHelper do
  include AuthorizationHelperMethods
  helper ApplicationInfoHelper

  context '.can_read_system_info?' do
    before(:each) do
      Resources::Candlepin::Owner.stub!(:create_user).and_return(true)
      Resources::Candlepin::Owner.should_receive(:create).at_least(:once).
        and_return({})
      disable_env_orchestration
      disable_user_orchestration
      Katello.config[:warden] = 'ldap'
      Katello.config[:validate_ldap] = false
      User.stub!(:cp_oauth_header).and_return("abc123")
      @org = Organization.create!(:name => "Haskell_Curry_Inc",
                                  :label => "haskell_curry_inc"
                                 )
      @user = User.create!(:username => "haskell",
                           :email => "hcurry@lambda.com"
                          )
    end

    it 'should return false if there is no current user' do
      can_read_system_info?.should eql(false)
    end

    it 'should return false for a user without org read access' do
      User.current = @user
      can_read_system_info?.should be_false
    end

    it 'should return true for a user with org read access' do
      User.current = @user
      allow(@user.own_role, [:read], :organizations, nil, @org)
      can_read_system_info?.should be_true
    end
  end
end
