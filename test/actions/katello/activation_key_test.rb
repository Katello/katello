require 'katello_test_helper'

module ::Actions::Katello::ActivationKey
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
    let(:activation_key) { katello_activation_keys(:simple_key) }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::ActivationKey::Create }

    it 'plans' do
      activation_key.expects(:save!)
      action.expects(:action_subject)
      plan_action action, activation_key
      assert_action_planed_with(action,
                                ::Actions::Candlepin::ActivationKey::Create,
                                :organization_label => activation_key.organization.label,
                                :auto_attach => true)
      assert_action_planed action, ::Actions::ElasticSearch::Reindex
    end

    it 'raises error when validation fails' do
      activation_key.name = nil
      proc { plan_action action, activation_key }.must_raise(ActiveRecord::RecordInvalid)
    end
  end

  class UpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::ActivationKey::Update }
    let(:input) { { :auto_attach => 'false' } }

    it 'plans' do
      activation_key.expects(:disable_auto_reindex!)
      action.expects(:action_subject).with(activation_key)
      activation_key.expects(:update_attributes!).with(input)
      plan_action(action, activation_key, input)
      assert_action_planed(action, ::Actions::Candlepin::ActivationKey::Update)
    end
  end

  class UpdateWithoutCandlepinTest < TestBase
    let(:action_class) { ::Actions::Katello::ActivationKey::Update }
    let(:input) { { :name => 'newName' } }

    it 'plans' do
      activation_key.expects(:disable_auto_reindex!)
      action.expects(:action_subject).with(activation_key)
      activation_key.expects(:update_attributes!).with(input)
      plan_action(action, activation_key, input)
      refute_action_planed(action, ::Actions::Candlepin::ActivationKey::Update)
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::ActivationKey::Destroy }

    it 'plans' do
      action = create_action(action_class)
      action.expects(:plan_self)
      action.expects(:action_subject).with(activation_key)
      plan_action(action, activation_key)
      assert_action_planed(action, ::Actions::Candlepin::ActivationKey::Destroy)
    end
  end
end
