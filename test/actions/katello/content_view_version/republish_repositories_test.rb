require 'katello_test_helper'

module Katello::Host
  class RepublishRepositoriesTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @version = katello_content_view_versions(:library_view_version_2)
    end

    describe 'Version Republish Repositories' do
      let(:action_class) { ::Actions::Katello::ContentViewVersion::RepublishRepositories }
      let(:action) { create_action action_class }

      it 'plans with default values' do
        action.stubs(:action_subject).with(@version.content_view)

        plan_action(action, @version)

        @version.repositories.each do |repo|
          assert_action_planed_with(action, Actions::Katello::Repository::MetadataGenerate, repo, :force => true)
        end

        @version.content_view_puppet_environments.each do |cvpe|
          assert_action_planed_with(action, Actions::Katello::Repository::MetadataGenerate, cvpe, :force => true)
        end
      end
    end
  end
end
