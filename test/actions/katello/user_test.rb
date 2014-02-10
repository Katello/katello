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

  describe ::Actions::Katello::User do
    include Dynflow::Testing
    include Support::Actions::Fixtures

    describe "Create" do
      let(:action_class) { ::Actions::Katello::User::Create }

      specify { assert ::Actions::Headpin::User::Create, action_class.subscribe }

      it 'plans' do
        user         = stub 'cp', remote_id: 'stubbed_user'
        action = create_and_plan_action action_class, user
        assert_action_planed_with(action,
                                  ::Actions::Pulp::User::Create,
                                  remote_id: 'stubbed_user')
        assert_action_planed_with(action,
                                  ::Actions::Pulp::User::SetSuperuser,
                                  remote_id: 'stubbed_user')
      end
    end
  end
end
