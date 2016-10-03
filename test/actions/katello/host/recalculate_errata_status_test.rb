require 'katello_test_helper'

module Katello::Host
  class RecalculateErrataStatusTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryGirl.create(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                                 :lifecycle_environment => katello_environments(:library))
    end

    describe 'run' do
      let(:action_class) { ::Actions::Katello::Host::RecalculateErrataStatus }

      it 'plans' do
        Katello::Host::ContentFacet.any_instance.expects(:update_errata_status).at_least_once
        ::ForemanTasks.sync_task(action_class)
      end
    end
  end
end
