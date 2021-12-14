require 'katello_test_helper'

module ::Actions::Katello
  class KatelloTestAction < Actions::EntryAction
    include Actions::Katello::CheckMatchingContent

    def plan_self(*args)
      check_matching_content(*args)
    end
  end

  class CheckMatchingContentTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
    include Actions::Katello::CheckMatchingContent

    let(:smart_proxy) { SmartProxy.new }
    let(:repo) { katello_repositories(:fedora_17_x86_64) }

    def test_plans_check_matching_content
      smart_proxy.stubs(:pulp3_support?).returns(true)
      action = create_action KatelloTestAction

      new_repo = FactoryBot.create(:katello_repository, :with_product)
      new_repo.environment = repo.environment

      plan_action(action, new_repo, [repo])

      assert_action_planned_with(action, Actions::Katello::Repository::CheckMatchingContent, :source_repo_id => repo.id, :target_repo_id => new_repo.id)
    end

    def test_does_not_plan_check_matching_content_without_target_repo_environment
      smart_proxy.stubs(:pulp3_support?).returns(true)
      action = create_action KatelloTestAction

      new_repo = FactoryBot.create(:katello_repository, :with_product)

      plan_action(action, new_repo, [repo])

      refute_action_planed(action, Actions::Katello::Repository::CheckMatchingContent)
    end

    def test_does_not_plan_check_matching_content_with_multiple_source_repositories
      smart_proxy.stubs(:pulp3_support?).returns(true)
      action = create_action KatelloTestAction

      new_repo = FactoryBot.create(:katello_repository, :with_product)
      new_repo.environment = repo.environment
      another_source_repo = FactoryBot.create(:katello_repository, :with_product)

      plan_action(action, new_repo, [repo, another_source_repo])

      refute_action_planed(action, Actions::Katello::Repository::CheckMatchingContent)
    end

    def test_does_not_plan_check_matching_content_when_repo_content_type_fails_metadata_publish_matching_check
      smart_proxy.stubs(:pulp3_support?).returns(true)
      action = create_action KatelloTestAction

      new_repo = FactoryBot.create(:katello_repository, :with_product)
      new_repo.environment = repo.environment

      ::Katello::RepositoryTypeManager.find(new_repo.content_type).stubs(:metadata_publish_matching_check).returns(false)
      plan_action(action, new_repo, [repo])

      refute_action_planed(action, Actions::Katello::Repository::CheckMatchingContent)
    end
  end
end
