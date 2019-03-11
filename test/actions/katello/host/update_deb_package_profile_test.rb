require 'katello_test_helper'

module Katello::Host
  class UpdateDebPackageProfileTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.build(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                                 :lifecycle_environment => katello_environments(:library), :id => 343)
    end

    describe 'Host UpdateDebPackageProfile' do
      let(:action_class) { ::Actions::Katello::Host::UpdateDebPackageProfile }
      let(:deb_packages) do
        [{:name => "pi", :architecture => "transcendent", :version => "3.14159"}]
      end

      it 'plans' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        plan_action action, @host, deb_packages

        assert_action_planed_with action, Actions::Katello::Host::GenerateApplicability, [@host]
      end

      it 'runs' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host)
        @host.expects(:installed_deb_ids=).with(any_parameters)
        @host.expects(:save!)

        plan_action action, @host, deb_packages
        run_action action
      end

      it 'runs and no raised exception if host not found' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(nil)
        ::Katello::Pulp::Consumer.expects(:new).never

        plan_action action, @host, deb_packages
        run_action action
      end

      it 'runs and no raised exception if host not found via FK error' do
        action = create_action action_class
        action.stubs(:action_subject).with(@host)

        ::Host.expects(:find_by).returns(@host)
        @host.expects(:save!).raises(ActiveRecord::InvalidForeignKey)

        plan_action action, @host, deb_packages
        run_action action
      end
    end
  end
end
