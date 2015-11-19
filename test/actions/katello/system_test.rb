require 'katello_test_helper'
require 'support/host_support'

module ::Actions::Katello::System
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
  end

  class UpdateTest < TestBase
    before do
      puppet_env = ::Environment.create!(:name => 'blah')

      cvpe = library_dev_staging_view.version(dev).puppet_env(dev)
      cvpe.puppet_environment = puppet_env
      cvpe.save!

      foreman_host = FactoryGirl.create(:host)
      system.host_id = foreman_host.id
      system.content_view = library_view
      system.environment = library
      system.save!
      action.expects(:action_subject).with(system)
    end

    let(:action_class) { ::Actions::Katello::System::Update }
    let(:input) { { :name => 'newname' } }

    let(:acme_default) { ::Katello::ContentView.find(katello_content_views(:acme_default)) }
    let(:library_view) { ::Katello::ContentView.find(katello_content_views(:library_view)) }
    let(:library) { ::Katello::KTEnvironment.find(katello_environments(:library)) }
    let(:dev) { ::Katello::KTEnvironment.find(katello_environments(:dev).id) }
    let(:library_dev_staging_view) { ::Katello::ContentView.find(katello_content_views(:library_dev_staging_view)) }
    let(:system) do
      ::Katello::System.find(katello_systems(:simple_server))
    end

    it 'plans' do
      stub_remote_user
      system.expects(:update_attributes!).with(input)

      plan_action(action, system, input)

      assert_action_planed_with(action, ::Actions::Katello::Host::Update, system.foreman_host)
    end

    it 'errors if content view and env dont have matching puppet env' do
      stub_remote_user
      Support::HostSupport.setup_host_for_view(system.foreman_host, library_dev_staging_view, dev, true)

      system.content_view = acme_default
      system.environment = library
      # If a puppet environment cannot be found for the lifecycle environment + content view
      # combination, then an error should be raised
      assert_raises ::Katello::Errors::NotFound do
        plan_action(action, system, input)
      end
    end

    it 'properly updates puppet env' do
      stub_remote_user
      Support::HostSupport.setup_host_for_view(system.foreman_host, library_view, library, true)
      system.reload
      system.environment = dev
      system.content_view = library_dev_staging_view
      system.save!

      plan_action(action, system, input)

      host = ::Host.find(system.foreman_host)
      assert_equal host.lifecycle_environment, dev
      assert_equal host.content_view, library_dev_staging_view
      assert_equal host.environment.content_view, library_dev_staging_view
      assert_equal host.environment.lifecycle_environment, dev
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::System::Destroy }

    let(:system) { Katello::System.find(katello_systems(:simple_server)) }

    it 'plans' do
      stub_remote_user
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
