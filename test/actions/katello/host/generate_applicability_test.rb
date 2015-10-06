require 'katello_test_helper'

module Katello::Host
  class UploadPackageProfileTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @host = FactoryGirl.build(:host, :with_content, :with_subscription, :content_view => katello_content_views(:library_dev_view),
                                 :lifecycle_environment => katello_environments(:library))
    end

    describe 'Host Generate Applicability' do
      let(:action_class) { ::Actions::Katello::Host::GenerateApplicability }

      it 'plans' do
        action = create_action action_class

        plan_action action, [@host]

        assert_action_planed_with action, Actions::Pulp::Consumer::GenerateApplicability, :uuids => [@host.content_aspect.uuid]
      end
    end
  end
end
