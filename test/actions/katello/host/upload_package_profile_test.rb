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

    describe 'Host UploadPackageProfile' do
      let(:action_class) { ::Actions::Katello::Host::UploadPackageProfile }

      it 'plans' do
        profile = [{:name => "foo", :version => "1", :release => "3"}]
        action = create_action action_class
        @host.expects(:import_package_profile)
        ::Katello::Pulp::Consumer.any_instance.expects(:upload_package_profile)
        action.stubs(:action_subject).with(@host)

        plan_action action, @host, profile

        assert_action_planed_with action, Actions::Katello::Host::GenerateApplicability, [@host]
      end
    end
  end
end
