require 'katello_test_helper'

module ::Actions::Pulp3::Repository
  class DeleteDistributionsTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction

    let(:action_class) { ::Actions::Pulp3::Repository::DeleteDistributions }

    before do
      stub_remote_user
    end

    it 'finalize does not raise when repository is already destroyed' do
      smart_proxy = SmartProxy.pulp_primary
      planned_action = create_and_plan_action(
        action_class,
        -1,
        smart_proxy
      )

      assert_nil ::Katello::Repository.find_by(id: -1)
      assert_nothing_raised do
        finalize_action(planned_action)
      end
    end
  end
end
