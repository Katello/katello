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

describe Glue::Foreman::User do

  unless Katello.config.use_foreman
    pending 'foreman is not enabled, skipping'
  else

    before do
      disable_user_orchestration :keep_foreman => true
      ::Foreman::User.stub(:new).and_return(foreman_user)
    end

    let(:foreman_user) { mock('foreman_user', :save! => true, :id => 1) }
    let(:user) do
      User.new(:username => "TestUser", :password => "foobar", :email => "TestUser@somewhere.com").tap do |user|
        user.stub(:foreman_user).and_return(foreman_user)
        user.stub(:foreman).and_return(foreman_user)
      end
    end

    it "should create foreman user" do
      foreman_user.should_receive :save!
      user.save!
      user.reload.foreman_id.should == foreman_user.id
    end

    it "should update foreman user" do
      user.save!
      user.email = email = 'an_email@example.com'
      foreman_user.should_receive(:attributes=).with(hash_including(:mail => email))
      foreman_user.should_receive :save!
      user.save!
    end

    it "should destroy foreman user" do
      user.save!
      user.reload
      User.stub(:current).and_return(mock('current user', :id => 15))
      foreman_user.should_receive(:destroy!).and_return(true)
      user.destroy.should be_true
    end
  end
end
