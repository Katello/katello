#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
    stub_remote_user
  end

  it 'plans' do
    plan_action(action, environment, content_view)
    assert_finalize_phase(action)
    action.input.must_equal("environment_id" => environment.id,
                            "content_view_id" => content_view.id,
                            "remote_user" => "user",
                            "remote_cp_user" => "user")
  end

  it 'updates the foreman content' do
    ::Katello::Foreman.expects(:update_puppet_environment).with do |view, env|
      env.id.must_equal environment.id
      view.id.must_equal content_view.id
    end
    plan_action(action, environment, content_view)
    finalize_action(action)
  end
end
