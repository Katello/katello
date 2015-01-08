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

class Actions::Candlepin::ActivationKey::CreateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe 'Create' do
    let(:action_class) { ::Actions::Candlepin::ActivationKey::Create }
    let(:planned_action) do
      create_and_plan_action(action_class, uuid: 123)
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::ActivationKey.expects(:create)
      run_action planned_action
    end
  end
end

class Actions::Candlepin::ActivationKey::UpdateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe 'Update' do
    let(:action_class) { ::Actions::Candlepin::ActivationKey::Update }
    let(:input) { { :cp_id => 'foo_boo', :auto_attach => 'false' } }

    let(:planned_action) do
      create_and_plan_action(action_class, input)
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::ActivationKey.expects(:update)
      run_action planned_action
    end
  end
end

class Actions::Candlepin::ActivationKey::DestroyTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  before do
    stub_remote_user
  end

  describe "Destroy" do
    let(:action_class) { ::Actions::Candlepin::ActivationKey::Destroy }
    let(:cp_id) { "foo_boo" }
    let(:planned_action) do
      create_and_plan_action(action_class, cp_id: cp_id)
    end

    it 'runs' do
      ::Katello::Resources::Candlepin::ActivationKey.expects(:destroy).with(cp_id)
      run_action planned_action
    end
  end
end
