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
include OrchestrationHelper

describe SyncPlan, :katello => true do

  describe "SyncPlan should" do
    before(:each) do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @plan = SyncPlan.create!({:name => 'Norman Rockwell', :organization => @organization, :sync_date => DateTime.now, :interval => 'daily'})
    end

    it "be able to create" do
      @plan.should_not be_nil
    end

    it "be able to gracefull handle invalid intervals" do
      @plan.interval = 'notgood'
      @plan.should_not be_valid
    end

    it "be able to modify valid intervals" do
      @plan.interval = 'weekly'
      @plan.should be_valid
    end

    it "be able to update" do
      p = SyncPlan.find_by_name('Norman Rockwell')
      p.should_not be_nil
      new_name = p.name + "N"
      p = SyncPlan.update(p.id, {:name => new_name})
      p.name.should == new_name
    end

    it "be able to delete" do
      p = SyncPlan.find_by_name('Norman Rockwell')
      pid = p.id
      p.destroy

      lambda{SyncPlan.find(pid)}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should have proper pulp duration format" do
      @plan.interval = 'weekly'
      @plan.schedule_format.should_not be_nil
      @plan.schedule_format.should =~ /\/P7D$/
    end

    it "should properly handle pulp duration of none" do
      @plan.interval = 'none'
      @plan.sync_date = DateTime.now.tomorrow()
      @plan.schedule_format.should_not be_nil
      @plan.schedule_format.should =~ /R1\/.*\/P1D/
    end

    it "should properly handle pulp duration of none if scheduled in past" do
      @plan.interval = 'none'
      @plan.sync_date = DateTime.now.yesterday()
      @plan.schedule_format.should == nil
    end

    it "reassign sync_plan to its products after update" do
      disable_product_orchestration

      organization = Organization.create!(:name=>ProductTestData::ORG_ID, :label => 'admin-org-37070')
      @plan.products.create! ProductTestData::SIMPLE_PRODUCT.merge(
                                 :provider => organization.redhat_provider, :environments => [organization.library])
      @plan.save!
      @plan.reload
      @plan.should have(1).products

      #updating plan
      @plan.sync_date += 1
      @plan.products.to_a.first.should_receive(:setup_sync_schedule).and_return(true)
      lambda { @plan.save! }.should_not raise_exception
    end
  end

end
