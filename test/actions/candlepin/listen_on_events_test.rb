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

class Actions::Candlepin::ListenOnCandlepinEventsTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  describe 'run' do
    let(:action_class) { ::Actions::Candlepin::ListenOnCandlepinEvents }
    let(:planned_action) do
      create_and_plan_action action_class
    end

    it 'reindexes and acknowledges messages' do
      Actions::Candlepin::ListenOnCandlepinEvents.any_instance.stubs(:suspend)
      Actions::Candlepin::CandlepinListeningService.any_instance.stubs(:create_connection)
      listening_service = Actions::Candlepin::CandlepinListeningService.new(nil, nil, nil)
      listening_service.messages.add(123, OpenStruct.new(:subject => 'entitlement.created'))
      Actions::Candlepin::CandlepinListeningService.stubs(:instance).returns(listening_service)

      Actions::Candlepin::ReindexPoolSubscriptionHandler.any_instance.expects(:handle)
      Actions::Candlepin::CandlepinListeningService.any_instance.expects(:acknowledge_message)

      action = run_action planned_action
      action.run(Actions::Candlepin::ListenOnCandlepinEvents::Event[123])
    end
  end
end
