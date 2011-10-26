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
include OrchestrationHelper
include AuthorizationHelperMethods
describe User do

  USERNAME = "testuser"
  PASSWORD = "password1234"

  let(:to_create_simple) do
    {
      :username => USERNAME,
      :password => PASSWORD
    }
  end

  context "Pulp orchestration" do
    before(:each) { disable_user_orchestration }

    it "should call pulp user create api during user creation" do
      Pulp::User.should_receive(:create).once.with(hash_including(:login => USERNAME, :name => USERNAME)).and_return({})
      User.create!(to_create_simple)
    end

    it "should call pulp role api during user creation" do
      Pulp::Roles.should_receive(:add).once.with("super-users", USERNAME).and_return(true)
      User.create!(to_create_simple)
    end

    it "should call pulp user delete api during user deletion" do
      u = User.create!(to_create_simple)

      Pulp::User.should_receive(:destroy).once.with(USERNAME).and_return(200)
      u.destroy
    end

    it "should call pulp role api during user deletion" do
      u = User.create!(to_create_simple)

      Pulp::Roles.should_receive(:remove).once.with("super-users", USERNAME).and_return(true)
      u.destroy
    end
  end

end
