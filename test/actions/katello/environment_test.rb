require 'katello_test_helper'

module ::Actions::Katello::Environment
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryBot::Syntax::Methods

    let(:action) { create_action action_class }

    before do
      set_user
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::Environment::Destroy }
    let(:action) { create_action action_class }

    let(:environment) { stub }

    it 'plans' do
      stub_remote_user
      content_view = stub
      cve = mock(:content_view => content_view)
      action.stubs(:action_subject).with(environment)
      environment.expects(:content_view_environments).returns([cve])
      environment.expects(:deletable?).returns(true)
      plan_action(action, environment)
      assert_action_planned_with(action, ::Actions::Katello::ContentView::Remove, content_view, :content_view_environments => [cve], :skip_repo_destroy => false, :organization_destroy => false)
    end
  end
end
