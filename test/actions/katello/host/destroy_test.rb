require 'katello_test_helper'

module Katello::Host
  class DestroyTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @content_view = katello_content_views(:library_dev_view)
      @library = katello_environments(:library)
      @host = FactoryBot.build(:host, :with_content, :with_subscription, :content_view => @content_view,
                                 :lifecycle_environment => @library)
    end

    describe 'Host Destroy' do
      let(:action_class) { ::Actions::Katello::Host::Destroy }

      it 'plans with default values' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find).returns(@host)
        ::Katello::RegistrationManager.expects(:unregister_host).with(@host, :unregistering => false, :organization_destroy => false)

        plan_action action, @host
        run_action action
      end

      it 'plans and host has since been deleted' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find).raises(ActiveRecord::RecordNotFound)
        ::Katello::RegistrationManager.expects(:unregister_host).never

        plan_action action, @host
        run_action action
      end

      it 'plans with unregistering true' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find).returns(@host)
        ::Katello::RegistrationManager.expects(:unregister_host).with(@host, :unregistering => true, :organization_destroy => false)

        plan_action action, @host, :unregistering => true
        run_action action
      end

      it 'plans with organization_destroy true' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find).returns(@host)
        ::Katello::RegistrationManager.expects(:unregister_host).with(@host, :unregistering => false, :organization_destroy => true)

        plan_action action, @host, :organization_destroy => true
        run_action action
      end
    end
  end
end
