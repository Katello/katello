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

module Katello

  describe ::Actions::Katello::System do
    include Dynflow::Testing
    include FactoryGirl::Syntax::Methods

    describe "Create" do
      let(:action_class) { ::Actions::Katello::System::Create }
      let(:trigger_class) { ::Actions::Headpin::System::Create }

      specify { assert trigger_class, action_class.subscribe }

      it 'plans' do
        system = build(:katello_system, :alabama)
        trigger = create_action trigger_class
        trigger.input[:uuid] = 123
        action = create_action(action_class, trigger)
        plan_action action, system
        assert_action_planed_with(action,
                                  ::Actions::Pulp::Consumer::Create,
                                  uuid: 123,
                                  name: 'Alabama')
      end
    end
  end
end
