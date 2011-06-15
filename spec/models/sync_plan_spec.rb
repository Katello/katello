require 'spec_helper'
include OrchestrationHelper

describe SyncPlan do

  describe "SyncPlan should" do
    before(:each) do
      disable_org_orchestretion
      @organization = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
      @plan = SyncPlan.create!({:name => 'Norman Rockwell', :organization_id => @organization, :sync_date => DateTime.now, :interval => 'daily'})
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
      @plan.schedule_format.should be_any { |m| m =~ /\/P7D$/ }
    end

    it "should properly handle pulp duration of none" do
      @plan.interval = 'none'
      @plan.schedule_format.should_not be_nil
      @plan.schedule_format.should_not =~ /\//
    end

  end

end
