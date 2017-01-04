require 'katello_test_helper'

module Katello::Host
  class DestroyTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before :all do
      User.current = users(:admin)
      @version = katello_content_view_versions(:library_view_version_2)
    end

    describe 'Version Destroy' do
      let(:action_class) { ::Actions::Katello::ContentViewVersion::Destroy }
      let(:action) { create_action action_class }

      it 'plans with default values' do
        options = {:skip_environment_check => true}
        plan_action(action, @version, options)

        options[:planned_destroy] = true
        @version.repositories.each do |repo|
          assert_action_planed_with(action, Actions::Katello::Repository::Destroy, repo, options)
        end

        @version.content_view_puppet_environments.each do |cvpe|
          assert_action_planed_with(action, Actions::Katello::ContentViewPuppetEnvironment::Destroy, cvpe)
        end
      end

      it 'plans with nil content_view_puppet_environments values' do
        @version.stubs(:archive_puppet_environment).returns(nil)
        options = {:skip_environment_check => true, :skip_destroy_env_content => true}
        plan_action(action, @version, options)

        options[:planned_destroy] = true
        @version.archived_repos.each do |repo|
          assert_action_planed_with(action, Actions::Katello::Repository::Destroy, repo, options)
        end

        refute_action_planed(action, Actions::Katello::ContentViewPuppetEnvironment::Destroy)
      end
    end
  end
end
