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

class Dynflow::Testing::DummyPlannedAction

  attr_accessor :error

end


module ::Actions::Katello::Repository

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
    let(:repository) { katello_repositories(:rhel_6_x86_64) }
    let(:custom_repository) { katello_repositories(:fedora_17_x86_64) }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Create }

    it 'plans' do
      repository.expects(:save!)
      action.expects(:action_subject).with(repository)
      action.execution_plan.stub_planned_action(::Actions::Katello::Product::ContentCreate) do |content_create|
        content_create.stubs(input: { content_id: 123 })
      end
      plan_action action, repository
    end
  end

  class CreateFailTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Create }
    before do
      Dynflow::Testing::DummyPlannedAction.any_instance.stubs(:error).returns("ERROR")
    end


    it 'fails to plan' do
      repository.expects(:save!).never
    end
  end

  class DestroyTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Destroy }
    let(:pulp_action_class) { ::Actions::Pulp::Repository::Destroy }

    it 'plans' do
      repository.expects(:destroy!)
      action       = create_action action_class
      action.stubs(:action_subject).with(repository)
      plan_action action, repository
      assert_action_planed_with action, pulp_action_class, pulp_id: repository.pulp_id
      assert_action_planed_with action, ::Actions::Katello::Product::ContentDestroy, repository
    end
  end

  class DyscoverTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Discover }
    let(:action_planned) { create_and_plan_action action_class, url = 'http://' }

    it 'plans' do
      assert_run_phase action_planned
    end

    it 'runs' do
      ::Katello::RepoDiscovery.
          expects(:new).
          returns(mock('discovery', run: nil))

      run_action action_planned
    end
  end

  class RemovePackagesTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::RemovePackages }

    it 'plans' do
      uuids = ['troy', 'and', 'abed', 'in_the_morning']
      action.expects(:action_subject).with(custom_repository)
      plan_action action, custom_repository, uuids
    end
  end

  class SyncTest < TestBase
    let(:action_class) { ::Actions::Katello::Repository::Sync }
    let(:pulp_action_class) { ::Actions::Pulp::Repository::Sync }

    it 'plans' do
      action       = create_action action_class
      action.stubs(:action_subject).with(repository)
      plan_action action, repository

      assert_action_planed_with action, pulp_action_class, pulp_id: repository.pulp_id
      assert_action_planed action, ::Actions::ElasticSearch::Repository::IndexContent
      assert_action_planed_with action, ::Actions::ElasticSearch::Reindex, repository
    end

    describe 'progress' do
      let :action do
        create_action(action_class).tap do |action|
          action.stubs(planned_actions: [pulp_action])
        end
      end

      let(:pulp_action) { fixture_action(pulp_action_class, input: {pulp_id: repository.pulp_id}, output: fixture_variant) }

      describe 'successfully synchronized' do
        let(:fixture_variant) { :success }

        specify do
          action.humanized_output.must_equal "New packages: 32 (76.7 KB)."
        end
      end

      describe 'successfully synchronized without new packages' do
        let(:fixture_variant) { :success_no_packages }

        specify do
          action.humanized_output.must_equal "No new packages."
        end
      end

      describe 'syncing packages in progress' do
        let(:fixture_variant) { :progress_packages }

        specify do
          action.humanized_output.must_equal "New packages: 20/32 (48 KB/76.7 KB)."
        end

        specify do
          pulp_action.run_progress.must_be_within_delta 0.6256
        end
      end

      describe 'downloading metadata in progress' do
        let(:fixture_variant) { :progress_metadata }

        specify do
          action.humanized_output.must_equal "Processing metadata"
        end
      end
    end
  end
end
