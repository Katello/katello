require 'katello_test_helper'
module ::Actions::Katello::ContentView
  class PromoteTest < ActiveSupport::TestCase
    include Dynflow::Testing

    let(:action) { create_action Promote }

    it 'plans' do
      version = katello_content_view_versions(:library_view_version_2)
      environment = katello_environments(:library)
      task = create(:dynflow_task)
      action.stubs(:task).returns(task)
      version.expects(:promotable?).returns(true)
      ::Katello::Util::CandlepinRepositoryChecker.expects(:check_repositories_for_promote!)

      plan_action action, version, [environment]
    end
  end
end
