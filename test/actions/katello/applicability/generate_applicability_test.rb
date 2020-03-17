require 'katello_test_helper'

module ::Actions::Katello::Applicability::Host
  class GenerateApplicabilityTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.build(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                               :lifecycle_environment => katello_environments(:library))
      SETTINGS[:katello][:katello_applicability] = true
    end

    after :all do
      SETTINGS[:katello][:katello_applicability] = false
    end

    describe 'Host Generate Applicability using Katello Applicability' do
      let(:action_class) { ::Actions::Katello::Host::GenerateApplicability }

      it 'plans' do
        action = create_action action_class

        plan_action action, [@host]

        assert_action_planed_with(action, Actions::Katello::Applicability::Hosts::Generate,
                                         :host_ids => [@host.id])
      end
    end
  end
end
