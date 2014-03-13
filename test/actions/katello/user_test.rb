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

module ::Actions::Katello::User

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:action) { create_action action_class }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::User::Create }

    it 'plans' do
      user = stub('cp',
                  remote_id: 'stubbed_user',
                  disable_auto_reindex!: true)
      action.stubs(:action_subject).with(user)
      plan_action(action, user)
      assert_action_planed_with(action, ::Actions::Pulp::User::Create, remote_id: 'stubbed_user')
      assert_action_planed_with(action,
                                ::Actions::Pulp::User::SetSuperuser, remote_id: 'stubbed_user')
      assert_action_planed_with(action, ::Actions::ElasticSearch::Reindex, user)
    end
  end
end
