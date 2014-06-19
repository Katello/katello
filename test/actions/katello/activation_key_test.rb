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

module ::Actions::Katello::ActivationKey

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::ActivationKey::Destroy }

    let(:activation_key) { katello_activation_keys(:simple_key) }

    it 'plans' do
      activation_key.expects(:destroy!)

      action = create_action(action_class)
      action.expects(:action_subject).with(activation_key)
      plan_action(action, activation_key)
      assert_action_planed(action, ::Actions::Candlepin::ActivationKey::Destroy)
    end
  end

end
