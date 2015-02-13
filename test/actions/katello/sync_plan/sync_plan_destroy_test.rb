#
# Copyright 2015 Red Hat, Inc.
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

describe ::Actions::Katello::SyncPlan::Destroy do
  include Dynflow::Testing
  include Support::Actions::Fixtures
  include FactoryGirl::Syntax::Methods

  before :all do
    @product = FactoryGirl.build('katello_product', provider: @provider, cp_id: 1234)
    @sync_plan = FactoryGirl.build('katello_sync_plan', :products => [@product])
  end

  let(:action_class) { ::Actions::Katello::SyncPlan::Destroy }
  let(:action) { create_action action_class }

  it 'plans' do
    action.stubs(:action_subject).with(@sync_plan)
    action.expects(:plan_self)

    plan_action(action, @sync_plan)

    assert_action_planed_with(action, ::Actions::Katello::Product::Update, @product, :sync_plan_id => nil)
  end
end
