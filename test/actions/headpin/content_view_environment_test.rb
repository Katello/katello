#
# Copyright 2013 Red Hat, Inc.
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

module Katello

  describe ::Actions::Headpin::ContentView do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryGirl::Syntax::Methods

    describe "Create" do
      let(:action_class) { ::Actions::Headpin::ContentView::EnvironmentCreate }
      let(:action) { create_action action_class }

      let(:content_view_environment) do
        katello_content_view_environments(:library_default_view_environment)
      end

      it 'plans' do
        Katello::Configuration::Node.any_instance.stubs(:use_cp).returns(true)
        content_view_environment.expects(:save!)
        plan_action(action, content_view_environment)
        content_view = content_view_environment.content_view
        assert_action_planed_with(action,
                                  ::Actions::Candlepin::Environment::Create,
                                  'organization_label' => content_view.organization.label,
                                  'cp_id' => content_view_environment.cp_id,
                                  'name' => content_view_environment.label,
                                  'description' => content_view.description)
      end
    end
  end
end
