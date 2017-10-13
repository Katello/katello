require 'katello_test_helper'

module Actions
  describe Katello::Repository::CheckMatchingContent do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Repository::CheckMatchingContent }
    let(:yum_repo) { katello_repositories(:fedora_17_x86_64) }
    let(:yum_repo2) { katello_repositories(:fedora_17_x86_64_dev) }

    def test_check_matching_content_false
      action = create_action(action_class)
      plan = plan_action(action, :source_repo_id => yum_repo.id, :target_repo_id => yum_repo2.id)
      run = run_action plan

      assert_equal false, run.output[:matching_content]
    end

    def test_check_matching_content_false_unpublished
      action = create_action(action_class)
      ::Katello::Repository.any_instance.expects(:published?).returns(false)
      plan = plan_action(action, :source_repo_id => yum_repo.id, :target_repo_id => yum_repo.id)
      run = run_action plan

      assert_equal false, run.output[:matching_content]
    end

    def test_check_matching_content_true
      action = create_action(action_class)
      ::Katello::Repository.any_instance.expects(:published?).returns(true)
      plan = plan_action(action, :source_repo_id => yum_repo.id, :target_repo_id => yum_repo.id)
      run = run_action plan

      assert_equal true, run.output[:matching_content]
    end
  end
end
