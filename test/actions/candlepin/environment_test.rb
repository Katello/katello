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

class Actions::Candlepin::Environment::CreateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  let(:action_class) { ::Actions::Candlepin::Environment::Create }
  let(:label) { "foo" }
  let(:name) { "boo" }
  let(:cp_id) { "foo_boo" }
  let(:description) { "great gatsby" }

  let(:planned_action) do
    create_and_plan_action(action_class,
                           organization_label: label,
                           name: name,
                           cp_id: cp_id,
                           description: description)
  end

  it 'runs' do
    ::Katello::Resources::Candlepin::Environment.expects(:create).with(label, cp_id, name, description)
    run_action planned_action
  end
end
