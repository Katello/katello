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

class Actions::Candlepin::Product::ContentUpdateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe 'ContentUpdate' do
    let(:action_class) { ::Actions::Candlepin::Product::ContentUpdate }
    let(:planned_action) do
      create_and_plan_action action_class, id: 123
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::Content.expects(:update)
      run_action planned_action
    end
  end
end
