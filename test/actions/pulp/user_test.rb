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

module ::Actions::Pulp::User
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction

    before do
      stub_remote_user
    end

    describe 'Create' do
      it 'runs' do
        planned_action = create_and_plan_action ::Actions::Pulp::User::Create,
                                                remote_id: 'user_id'

        run_action planned_action do |action|
          runcible_expects(action, :resources, :user, :create)
        end
      end
    end

    describe 'Superuser' do

      { ::Actions::Pulp::Superuser::Add    => :add,
        ::Actions::Pulp::Superuser::Remove => :remove
      }.each do |action, method|
        describe action.to_s.demodulize do
          specify do
            planned_action = create_and_plan_action action,
                                                    remote_id: 'user_id'
            run_action planned_action do |action|
              runcible_expects(action, :resources, :role, method)
            end
          end
        end
      end
    end
  end

end
