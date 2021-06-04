require 'katello_test_helper'

module Actions::Katello::Repository
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods
  end

  class VerifyChecksumTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::VerifyChecksum }

    let(:repository) do
      katello_repositories(:fedora_17_x86_64_dev)
    end

    it 'plans repair for pulp3 yum repositorites' do
      SmartProxy.any_instance.stubs(:pulp3_support?).returns(true)
      tree = plan_action_tree(action_class, repository)
      assert_tree_planned_with(tree, Actions::Pulp3::Repository::Repair)
    end
  end
end
