#
# Copyright 2011 Red Hat, Inc.
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

describe User do

  let(:to_create_simple) do
    {
      :username => "testuser",
      :password => "password1234",
    }
  end

  describe "User should" do
    before(:each) do
      @user = User.create!(to_create_simple)
    end

    it "be able to create" do
      u = User.find_by_username("testuser")
      u.should_not be_nil
    end

    it "have its own role" do
      #pending "implement own_role functionality"
      @user.own_role.should_not be_nil
    end

    specify { @user.cp_oauth_header.should == {'cp-user' => @user.username}}
    specify { @user.pulp_oauth_header.should == {'pulp-user' => @user.username}}
  end

end
