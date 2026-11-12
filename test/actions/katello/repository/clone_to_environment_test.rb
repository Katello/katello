require 'katello_test_helper'

module ::Actions::Katello::Repository
  class CloneToEnvironmentTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures

    let(:action_class) { ::Actions::Katello::Repository::CloneToEnvironment }
    let(:action) { create_action action_class }
    let(:repository) { katello_repositories(:fedora_17_x86_64) }
    let(:environment) { katello_environments(:dev) }

    before do
      User.current = users(:admin)
    end

    it 'plans the content clone for the environment' do
      action.stubs(:find_or_build_environment_clone).returns(katello_repositories(:fedora_17_x86_64_dev))

      plan_action(action, repository, environment, :assume_content_guard_exists => true)

      assert_action_planned(action, ::Actions::Katello::Repository::CloneContents)
    end

    it 'passes on whether the content changed' do
      clone = katello_repositories(:fedora_17_x86_64_dev)
      action.stubs(:find_or_build_environment_clone).returns(clone)

      plan_action(action, repository, environment, :contents_changed => false)

      assert_action_planned_with(action, ::Actions::Katello::Repository::CloneContents, [repository], clone,
                                 :copy_contents => false, :contents_changed => false,
                                 :assume_content_guard_exists => false)
    end
  end
end
