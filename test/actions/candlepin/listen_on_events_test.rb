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

    it 'initializes when configuration present' do
      ::Actions::Candlepin::CandlepinListeningService.stubs(:new).at_least_once
      action_class.stubs(:connect_listening_service)

      Katello.config[:qpid] = {:url => 'url', :subscriptions_queue_address => 'addr'}
      ::Actions::Candlepin::ListenOnCandlepinEvents.any_instance.stubs(:configured?).returns(true)
      run_action planned_action
    end

    it 'does not intialize when configuration missing' do
      ::Actions::Candlepin::CandlepinListeningService.stubs(:new).never
      action_class.stubs(:connect_listening_service)

      ::Actions::Candlepin::ListenOnCandlepinEvents.any_instance.stubs(:configured?).returns(false)
      run_action planned_action
    end

    it 'reindexes and acknowledges messages' do
      Actions::Candlepin::ListenOnCandlepinEvents.any_instance.stubs(:suspend)
      Actions::Candlepin::CandlepinListeningService.any_instance.stubs(:create_connection)
      listening_service = Actions::Candlepin::CandlepinListeningService.new(nil, nil, nil)
      Actions::Candlepin::CandlepinListeningService.stubs(:instance).returns(listening_service)

      Actions::Candlepin::ReindexPoolSubscriptionHandler.any_instance.expects(:handle)

      action = run_action planned_action
      action.run(Actions::Candlepin::ListenOnCandlepinEvents::Event['123', 'subject.subject', 'json'])
    end
  end
end
