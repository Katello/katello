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

module ::Actions::Katello::Environment
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
  end

  class LibraryCreateTest < TestBase
    let(:action_class) { ::Actions::Katello::Environment::LibraryCreate }
    let(:action) { create_action action_class }

    let(:library) do
      katello_environments(:library)
    end

    let(:content_view) do
      katello_content_views(:library_view)
    end

    let(:content_view_environment) do
      katello_content_view_environments(:library_default_view_environment)
    end

    it 'plans' do
      library.expects(:save!)

      ::Katello::ContentView.expects(:create!).returns(content_view).with do |arg_hash|
        arg_hash[:default] == true
      end

      plan_action(action, library)

      assert_action_planed_with(action,
                                ::Actions::Katello::ContentView::Create,
                                content_view)
      assert_action_planed_with(action,
                                ::Actions::Katello::ContentView::AddToEnvironment,
                                content_view.versions.first, library)
      assert_action_planed_with(action,
                                ::Actions::Katello::Foreman::ContentUpdate,
                                library, content_view)
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::Environment::Destroy }
    let(:action) { create_action action_class }

    let(:environment) { stub }

    it 'plans' do
      content_view = stub
      cve = mock(:content_view => content_view)
      action.stubs(:action_subject).with(environment)
      environment.expects(:content_view_environments).returns([cve])
      environment.expects(:deletable?).returns(true)
      environment.expects(:organization).returns(mock)
      plan_action(action, environment)
      assert_action_planed_with(action, ::Actions::ElasticSearch::Reindex, environment)
      assert_action_planed_with(action, ::Actions::Katello::ContentView::Remove, content_view, :content_view_environments => [cve], :skip_repo_destroy => false, :organization_destroy => false)
    end
  end
end
