#
# Copyright 2015 Red Hat, Inc.
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

module ::Actions::Katello::ContentViewVersion
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods
  end

  class IncrementalUpdateTest < TestBase
    let(:action_class) { ::Actions::Katello::ContentViewVersion::IncrementalUpdate }
    let(:action) { create_action action_class }

    let(:library) do
      katello_environments(:library)
    end

    let(:content_view_version) do
      katello_content_view_versions(:library_view_version_2)
    end

    let(:library_repo) do
      katello_repositories(:rhel_7_x86_64)
    end

    it 'plans' do
      new_repo = ::Katello::Repository.new(:pulp_id => 387, :library_instance_id => library_repo.id)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_repository).returns(new_repo)
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:new_puppet_environment).returns(Katello::ContentViewPuppetEnvironment)

      task = ForemanTasks::Task::DynflowTask.create!(state: :success, result: "good")
      action.stubs(:task).returns(task)
      action.expects(:action_subject).with(content_view_version.content_view)
      plan_action(action, content_view_version, [library], :content => {:package_ids => ['foobar']})
      assert_action_planed_with(action, ::Actions::Pulp::Repository::CopyRpm,
                                :source_pulp_id => library_repo.pulp_id,
                                :target_pulp_id => new_repo.pulp_id,
                                :full_clauses => { :filters => {:association => {'unit_id' => {'$in' => ['foobar']}}}},
                                :override_config => {:resolve_dependencies => false}, :include_result => true)
    end
  end
end
