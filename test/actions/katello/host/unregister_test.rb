require 'katello_test_helper'

module Katello::Host
  class UnregisterTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @content_view = katello_content_views(:library_dev_view)
      @library = katello_environments(:library)
      @host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => @content_view,
                                 :lifecycle_environment => @library)
    end

    describe 'Host Unregister' do
      let(:action_class) { ::Actions::Katello::Host::Unregister }

      it 'plans' do
        action = create_action action_class

        plan_action action, @host

        assert_action_planed_with action, Actions::Katello::Host::Destroy, @host, :destroy_object => false, :destroy_aspects => false
      end
    end
  end
end
