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

module ::Actions::Katello::System
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::System::Create }

    let(:system) do
      env = build(:katello_k_t_environment,
                  :library,
                  organization: build(:katello_organization, :acme_corporation))
      build(:katello_system, :alabama, environment: env)
    end

    it 'plans' do
      stub_remote_user
      system.expects(:save!)
      action.stubs(:action_subject).with do |subject, _params|
        subject.must_equal(system)
      end
      #::Actions::Katello::System::ActivationKeys.any_instance.stubs(:error).returns(nil)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns(nil)
      plan_action(action, system, [])
      assert_action_planed(action, ::Actions::Candlepin::Consumer::Create)
      assert_action_planed_with(action, ::Actions::ElasticSearch::Reindex, system)
      assert_action_planed_with(action, ::Actions::Pulp::Consumer::Create) do |params, *_|
        params[:uuid].must_be_kind_of Dynflow::ExecutionPlan::OutputReference
        params[:uuid].subkeys.must_equal %w(response uuid)
      end
    end

    it 'updates the uuid in finalize method' do
      ::Katello::System.stubs(:find).with(123).returns(system)
      action.input[:remote_user] = 'user'
      action.input[:remote_cp_user] = 'user'
      action.input[:system] = { id:  123 }
      action.input[:uuid] = '123'
      system.expects(:save!)
      finalize_action action
      system.uuid.must_equal '123'
    end
  end

  class UpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::System::Update }
    let(:input) { { :name => 'newname' } }

    let(:system) do
      env = build(:katello_k_t_environment,
                  :library,
                  organization: build(:katello_organization, :acme_corporation))
      build(:katello_system, :alabama, environment: env)
    end

    it 'plans' do
      stub_remote_user
      system.expects(:disable_auto_reindex!)
      action.expects(:action_subject).with(system)
      system.expects(:update_attributes!).with(input)

      plan_action(action, system, input)
      assert_action_planed(action, ::Actions::Pulp::Consumer::Update)
      assert_action_planed(action, ::Actions::Candlepin::Consumer::Update)
      assert_action_planed(action, ::Actions::ElasticSearch::Reindex)
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::System::Destroy }

    let(:system) { Katello::System.find(katello_systems(:simple_server)) }

    it 'plans' do
      action.expects(:plan_self)
      action.stubs(:action_subject).with(system)

      plan_action(action, system)
      assert_action_planed(action, ::Actions::Candlepin::Consumer::Destroy)
      assert_action_planed(action, ::Actions::Pulp::Consumer::Destroy)
    end
  end

  class HostDestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::System::HostDestroy }
    it 'plans' do
      host = mock
      content_host = mock
      host.expects(:content_host).at_least(1).returns(content_host)
      host.expects(:id).at_least(1).returns(1)

      action.stubs(:action_subject).with(host)

      plan_action(action, host)
      assert_action_planed_with(action, ::Actions::Katello::System::Destroy, content_host)
    end
  end

  class ActivationKeyTest < TestBase
    let(:action_class) { ::Actions::Katello::System::ActivationKeys }

    let(:system) { Katello::System.new }

    let(:activation_keys) do
      [katello_activation_keys(:simple_key),
       katello_activation_keys(:library_dev_staging_view_key)]
    end

    it 'plans' do
      plan_action(action, system, activation_keys)

      assert_equal system.environment, activation_keys[1].environment
      assert_equal system.content_view, activation_keys[1].content_view
    end
  end
end
