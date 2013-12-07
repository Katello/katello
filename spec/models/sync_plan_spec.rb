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
require 'helpers/product_test_data'

module Katello
  describe SyncPlan, :katello => true do

    include OrchestrationHelper

    describe "SyncPlan should" do
      before(:each) do
        @organization = get_organization(:organization1)
        @plan         = SyncPlan.create!({ :name => 'Norman Rockwell', :organization => @organization, :sync_date => DateTime.now, :interval => 'daily' })
      end

      it "be able to create" do
        @plan.wont_be_nil
      end

      it "be able to gracefull handle invalid intervals" do
        @plan.interval = 'notgood'
        @plan.wont_be :valid?
      end

      it "be able to modify valid intervals" do
        @plan.interval = 'weekly'
        @plan.must_be :valid?
      end

      it "be able to update" do
        p = SyncPlan.find_by_name('Norman Rockwell')
        p.wont_be_nil
        new_name = p.name + "N"
        p        = SyncPlan.update(p.id, { :name => new_name })
        p.name.must_equal(new_name)
      end

      it "be able to delete" do
        p   = SyncPlan.find_by_name('Norman Rockwell')
        pid = p.id
        p.destroy

        lambda { SyncPlan.find(pid) }.must_raise(ActiveRecord::RecordNotFound)
      end

      it "should have proper pulp duration format" do
        @plan.interval = 'weekly'
        @plan.schedule_format.wont_be_nil
        @plan.schedule_format.must_match(/\/P7D$/)
      end

      it "should properly handle pulp duration of none" do
        @plan.interval  = 'none'
        @plan.sync_date = DateTime.now.tomorrow()
        @plan.schedule_format.wont_be_nil
        @plan.schedule_format.must_match(/R1\/.*\/P1D/)
      end

      it "should properly handle pulp duration of none if scheduled in past" do
        @plan.interval  = 'none'
        @plan.sync_date = DateTime.now.yesterday()
        @plan.schedule_format.must_be_nil
      end

      it "reassign sync_plan to its products after update" do
        disable_product_orchestration

        organization = get_organization(:organization1)

        @plan.products.create! ProductTestData::SIMPLE_PRODUCT.merge(
                                   :provider => organization.redhat_provider)
        @plan.save!
        @plan.reload
        @plan.products.length.must_equal(1)

        #updating plan
        @plan.sync_date += 1
        @plan.products.to_a.first.expects(:setup_sync_schedule).returns(true)
        @plan.save!
        @plan.must_be :valid?
      end
    end

  end
end
