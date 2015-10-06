require 'katello_test_helper'

module ::Actions::Katello::System
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
  end

  class UpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::System::Update }
    let(:input) { { :name => 'newname' } }

    let(:system) do
      env = build(:katello_k_t_environment,
                  :library,
                  organization: build(:katello_organization, :acme_corporation))
      build(:katello_system, :alabama, :environment => env)
    end

    it 'plans' do
      stub_remote_user
      system.expects(:disable_auto_reindex!)
      action.expects(:action_subject).with(system)
      system.expects(:update_attributes!).with(input)

      plan_action(action, system, input)

      assert_action_planed_with(action, ::Actions::Katello::Host::Update, system.foreman_host)
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::System::Destroy }

    let(:system) { Katello::System.find(katello_systems(:simple_server)) }

    it 'plans' do
      action.stubs(:action_subject).with(system)
      system.foreman_host = ::Host.new

      plan_action(action, system)

      assert_action_planed_with(action, ::Actions::Katello::Host::Destroy, system.foreman_host, {})
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
