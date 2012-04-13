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


describe SystemGroup do

  before(:each) do
    disable_org_orchestration
    disable_consumer_group_orchestration
    @org = Organization.create!(:name => 'test_org', :cp_key => 'test_org')

  end

  context "create should" do

    it "should create succesfully with an org" do
      Pulp::ConsumerGroup.should_receive(:create).and_return({})
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp.pulp_id.should_not == nil
    end

    it "should not allow creation of a 2nd group in the same org with the same name" do
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp2 = SystemGroup.create(:name=>"TestGroup", :organization=>@org)
      grp2.new_record?.should == true
      SystemGroup.where(:name=>"TestGroup").count.should == 1
    end

    it "should allow systems groups with the same name to be creatd in different orgs" do
      @org2 = Organization.create!(:name => 'test_org2', :cp_key => 'test_org2')
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp2 = SystemGroup.create(:name=>"TestGroup", :organization=>@org2)
      grp2.new_record?.should == false
      SystemGroup.where(:name=>"TestGroup").count.should == 2
    end
  end

  context "delete should" do
    it "should delete a group successfully" do
      Pulp::ConsumerGroup.should_receive(:destroy).and_return(200)
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp.destroy
      SystemGroup.where(:name=>"TestGroup").count.should == 0
    end
  end

  context "update should" do

    it "should allow the name to change" do
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org)
      grp.name = "NotATestGroup"
      grp.save!
      SystemGroup.where(:name=>"NotATestGroup").count.should == 1
    end
  end

  context "changing consumer ids"  do
    it "should contact pulp if new ids are added" do
      Pulp::ConsumerGroup.should_receive(:add_consumer).twice
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org, :consumerids=>[:a, :b])
      grp.consumerids = [:a, :b, :c, :d]
      grp.save!
    end
    it "should contact pulp if new ids are removed" do
      Pulp::ConsumerGroup.should_receive(:delete_consumer).twice
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org, :consumerids=>[:a, :b])
      grp.consumerids = []
      grp.save!
    end
    it "should contact pulp if new ids are added and removed" do
      Pulp::ConsumerGroup.should_receive(:add_consumer).twice
      Pulp::ConsumerGroup.should_receive(:delete_consumer).twice
      grp = SystemGroup.create!(:name=>"TestGroup", :organization=>@org, :consumerids=>[:a, :b])
      grp.consumerids = [:c, :d]
      grp.save!
    end
  end
end
