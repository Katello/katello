require 'katello_test_helper'

module ::Actions::Katello::ActivationKey
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action) { create_action action_class }
    let(:activation_key) { katello_activation_keys(:purpose_attributes_key) }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::ActivationKey::Create }
    let(:candlepin_input) do
      {  :organization_label => activation_key.organization.label,
         :auto_attach => true,
         :service_level => 'Self-support',
         :release_version => activation_key.release_version,
         :purpose_usage => activation_key.purpose_usage,
         :purpose_role => activation_key.purpose_role,
         :purpose_addons => [katello_purpose_addons(:addon).name]
      }
    end
    it 'plans' do
      activation_key.expects(:save!)
      action.expects(:action_subject)

      plan_action action, activation_key, service_level: 'Self-support'

      assert_action_planned_with(action, ::Actions::Candlepin::ActivationKey::Create, **candlepin_input)
    end

    it 'raises error when validation fails' do
      activation_key.name = nil
      assert_raises(ActiveRecord::RecordInvalid) { plan_action action, activation_key }
    end
  end

  class UpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::ActivationKey::Update }
    let(:input) { { :auto_attach => 'false', :purpose_usage => "usage", :purpose_role => "role", :purpose_addon_ids => [katello_purpose_addons(:addon).id]} }

    it 'plans' do
      action.expects(:action_subject).with(activation_key)

      plan_action(action, activation_key, input)

      assert_action_planed(action, ::Actions::Candlepin::ActivationKey::Update)
      assert_equal(activation_key.purpose_usage, "usage")
      assert_equal(activation_key.purpose_role, "role")
      assert_equal(activation_key.purpose_addon_ids, [katello_purpose_addons(:addon).id])
      assert_equal(activation_key.auto_attach, false)
    end
  end

  class UpdateWithoutCandlepinTest < TestBase
    let(:action_class) { ::Actions::Katello::ActivationKey::Update }
    let(:input) { { :name => 'newName' } }

    it 'plans' do
      action.expects(:action_subject).with(activation_key)
      plan_action(action, activation_key, input)
      refute_action_planed(action, ::Actions::Candlepin::ActivationKey::Update)
      assert_equal(activation_key.name, 'newName')
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::ActivationKey::Destroy }

    it 'does not plan with missing cp_id' do
      action = create_action(action_class)
      action.expects(:plan_self)
      action.expects(:action_subject).with(activation_key)
      plan_action(action, activation_key)
      refute_action_planed(action, ::Actions::Candlepin::ActivationKey::Destroy)
      assert_nil(activation_key.cp_id)
    end

    it 'plans' do
      action = create_action(action_class)
      activation_key.update!(cp_id: 'something')
      action.expects(:plan_self)
      action.expects(:action_subject).with(activation_key)
      plan_action(action, activation_key)
      assert_action_planned_with(action, ::Actions::Candlepin::ActivationKey::Destroy, cp_id: activation_key.cp_id)
    end
  end
end
