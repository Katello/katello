#
# Copyright 2014 Red Hat, Inc.
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

module ::Actions::Katello::SyncPlan
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
    let(:sync_plan) { Katello::SyncPlan.find(katello_sync_plans(:sync_plan_hourly)) }
    let(:product) { Katello::Product.find(katello_products(:redhat)) }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::SyncPlan::UpdateProducts }

    it 'plans' do
      sync_plan.expects(:save!)
      action.expects(:action_subject)
      sync_plan.products << product

      plan_action action, sync_plan
      assert_action_planed_with(action, ::Actions::Katello::Product::Update, product, :sync_plan_id => sync_plan.id)
    end
  end
end
