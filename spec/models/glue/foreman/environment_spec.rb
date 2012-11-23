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

describe Glue::Foreman::Environment do

  unless AppConfig.use_foreman
    pending 'foreman is not enabled, skipping'
  else
    before do
      disable_org_orchestration :keep_foreman => true
      ::Foreman::Environment.stub(:new).and_return(foreman_environment)
      @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
    end

    let(:foreman_environment) { mock('foreman_environment', :save! => true, :id => 1) }
    let(:environment) do
      KTEnvironment.new(:name=>'TestEnv', :label=> 'test_env', :organization => @organization, :prior => @organization.library).tap do |environment|
        environment.stub(:foreman_environment).and_return(foreman_environment)
        environment.stub(:foreman).and_return(foreman_environment)
      end
    end

    it "should create foreman environment" do
      foreman_environment.should_receive :save!
      environment.save!
      environment.reload.foreman_id.should == foreman_environment.id
    end

    it "should destroy foreman environment" do
      environment.save!
      environment.reload
      KTEnvironment.stub(:current).and_return(mock('current environment', :id => 15))
      foreman_environment.should_receive(:destroy!).and_return(true)
      environment.destroy.should be_true
    end
  end
end
