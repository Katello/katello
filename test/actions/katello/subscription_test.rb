require 'katello_test_helper'

module ::Actions::Katello::Subscription
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryBot::Syntax::Methods

    let(:action) { create_action action_class }
  end

  class UpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::Subscription::Update }
    let(:subscription) { katello_subscriptions(:basic_subscription) }

    it 'plans' do
      plan_action action, subscription, :name => "Animal Product"
      assert_equal("Animal Product", subscription.name)
    end
  end
end
