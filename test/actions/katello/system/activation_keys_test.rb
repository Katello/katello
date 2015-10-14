require 'katello_test_helper'

module ::Actions::Katello::System
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:system) do
      system = katello_systems(:simple_server)
      system.foreman_host = hosts(:one)
      system
    end
    let(:host_collection_1) { katello_host_collections(:simple_host_collection) }
    let(:host_collection_2) { katello_host_collections(:another_simple_host_collection) }
    let(:host_collection_3) { katello_host_collections(:yet_another_host_collection) }
    let(:actkey0) do
      actkey0 = katello_activation_keys(:simple_key)
      actkey0.host_collection_ids = []
      actkey0
    end
    let(:actkey1) do
      actkey1 = katello_activation_keys(:another_simple_key)
      actkey1.host_collection_ids = [host_collection_1.id]
      actkey1
    end
    let(:actkey2) do
      actkey2 = katello_activation_keys(:yet_another_simple_key)
      actkey2.host_collection_ids = [host_collection_2.id, host_collection_3.id]
      actkey2
    end
    let(:actkey12) do
      actkey12 = katello_activation_keys(:and_yet_another_simple_key)
      actkey12.host_collection_ids = [host_collection_1.id, host_collection_2.id, host_collection_3.id]
      actkey12
    end
    let(:action_class) { ::Actions::Katello::System::ActivationKeys }
    let(:action) { create_action ::Actions::Katello::System::ActivationKeys }
  end

  class ActivationKeysTest < TestBase
    it 'nil activation keys' do
      plan_action(action, system, nil)
      assert_empty system.foreman_host.host_collection_ids
    end

    it 'empty activation keys' do
      plan_action(action, system, [])
      assert_empty system.foreman_host.host_collection_ids
    end

    it 'groups actkey0' do
      plan_action(action, system, [actkey0])
      assert_empty system.foreman_host.host_collection_ids
    end

    it 'groups actkey1' do
      plan_action(action, system, [actkey1])
      assert_equal system.foreman_host.host_collection_ids.sort, actkey1.host_collection_ids.sort
    end

    it 'groups actkey2' do
      plan_action(action, system, [actkey2])
      assert_equal system.foreman_host.host_collection_ids.sort, actkey2.host_collection_ids.sort
    end

    it 'groups actkey0, actkey1, actkey2, actkey12' do
      plan_action(action, system, [actkey0, actkey1, actkey2, actkey12])
      assert_equal system.foreman_host.host_collection_ids.sort, (actkey1.host_collection_ids + actkey2.host_collection_ids +
                                                                  actkey12.host_collection_ids).uniq.sort
    end
  end
end
