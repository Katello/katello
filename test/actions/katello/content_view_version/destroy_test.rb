require 'katello_test_helper'

module Katello::Host
  class DestroyTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @version = katello_content_view_versions(:library_view_version_2)
    end

    describe 'Version Destroy' do
      let(:action_class) { ::Actions::Katello::ContentViewVersion::Destroy }
      let(:action) { create_action action_class }

      it 'plans with default values' do
        options = {:skip_environment_check => true, :docker_cleanup => false}
        plan_action(action, @version, options)

        @version.repositories.each do |repo|
          assert_action_planned_with(action, Actions::Katello::Repository::Destroy, repo, **options)
        end
      end
    end
  end
end
