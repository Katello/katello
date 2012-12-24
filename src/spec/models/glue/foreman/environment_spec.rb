#
# Copyright 2012 Red Hat, Inc.
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

describe Glue::Foreman::Environment do

  let(:foreman_environment) { mock('foreman_environment', :save! => true, :id => rand(100)) }

  before(:each) do
    disable_org_orchestration
    disable_env_orchestration(:keep_foreman => true)

    User.stub(:current).and_return(mock('current user', :id => 15, :username => "current"))
    @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
    @environment = KTEnvironment.new({:name=>'test_environment', :label=> 'test_environment', :organization => @organization, :prior => @organization.library}).tap do |e|
      e.stub!(:foreman_environment).and_return(foreman_environment)
    end
  end

  context "Creating an Environment" do
    it "should create foreman environment" do
      foreman_environment.should_receive(:save!)
      @environment.save!
      @environment.foreman_id.should == foreman_environment.id
    end
  end

  context "Deleting an Environment" do
    it "should delete foreman environment" do
      @environment.save!

      foreman_environment.should_receive(:destroy!).and_return(true)
      @environment.destroy
    end
  end
end