require 'katello_test_helper'

module ::Actions::Katello::Applicability::Hosts
  class GenerateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryBot.build(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                               :lifecycle_environment => katello_environments(:library))
      @host.save!
      SETTINGS[:katello][:katello_applicability] = true
    end

    after :all do
      SETTINGS[:katello][:katello_applicability] = false
    end

    describe 'Host List Generate Applicability using Katello Applicability' do
      let(:action_class) { ::Actions::Katello::Applicability::Hosts::Generate }

      it 'plans' do
        action = create_action action_class

        plan_action action, host_ids: [@host.id]
        run_action action

        event = Katello::Event.find_by(event_type: Katello::Events::GenerateHostApplicability::EVENT_TYPE,
                                       object_id: @host.id)
        refute_nil event
      end
    end
  end
end
