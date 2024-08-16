require 'katello_test_helper'

class Actions::Katello::Foreman::ContentUpdateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  let(:action_class) { ::Actions::Katello::Foreman::ContentUpdate }
  let(:action) { create_action action_class }

  let(:environment) do
    katello_environments(:library)
  end

  let(:content_view) do
    katello_content_views(:library_view)
  end

  before do
    stub_remote_user(true)
  end

  it 'plans' do
    plan_action(action, environment, content_view)
    assert_finalize_phase(action)
    expected = {
      "environment_id" => environment.id,
      "content_view_id" => content_view.id,
      "repository_id" => nil,
      "remote_user" => SETTINGS[:katello][:pulp][:default_login],
      "remote_cp_user" => SETTINGS[:katello][:pulp][:default_login],
    }

    assert_equal expected, action.input
  end
end
