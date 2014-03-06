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

  describe ::Actions::Katello::Repository do
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    describe "Create" do
      let(:action_class) { ::Actions::Katello::Repository::Create }

      let(:repository) { build(:katello_repository, id: 123) }

      it 'plans' do
        action = create_action action_class
        repository.stubs(organization: build(:katello_organization))
        repository.expects(:save!)
        action.expects(:action_subject).with(repository)
        action.execution_plan.stub_planned_action(::Actions::Katello::Product::ContentCreate) do |content_create|
          content_create.stubs(input: { content_id: 123 })
        end
        plan_action action, repository
      end
    end

    describe 'Destroy' do
      let(:action_class) { ::Actions::Katello::Repository::Destroy }
      let(:pulp_action_class) { ::Actions::Pulp::Repository::Destroy }

      it 'plans' do
        repository   = mock 'repository', pulp_id: 123, destroy: true
        action       = create_action action_class
        action.stubs(:action_subject).with(repository)
        plan_action action, repository
        assert_action_planed_with action, pulp_action_class, pulp_id: 123
        assert_action_planed_with action, ::Actions::Katello::Product::ContentDestroy, repository
      end
    end

    describe 'Discover' do
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

    describe 'Sync' do

      let(:action_class) { ::Actions::Katello::Repository::Sync }
      let(:pulp_action_class) { ::Actions::Pulp::Repository::Sync }

      it 'plans' do
        repository   = mock 'repository', pulp_id: 'pulp-repo-1', id: 1
        action       = create_action action_class
        action.stubs(:action_subject).with(repository)
        plan_action action, repository

        assert_action_planed_with action, pulp_action_class, pulp_id: 'pulp-repo-1'
        assert_action_planed_with action, ::Actions::ElasticSearch::Repository::IndexContent, id: 1
        assert_action_planed_with action, ::Actions::ElasticSearch::Reindex, repository
      end

      describe 'progress' do
        let :action do
          create_action(action_class).tap do |action|
            action.stubs(planned_actions: [pulp_action])
          end
        end

        let(:pulp_action) { fixture_action(pulp_action_class, output: fixture_variant) }

        describe 'successfully synchronized' do
          let(:fixture_variant) { :success }

          specify do
            action.humanized_output.must_equal "New packages: 32 (76.7 KB)"
          end
        end

        describe 'successfully synchronized without new packages' do
          let(:fixture_variant) { :success_no_packages }

          specify do
            action.humanized_output.must_equal "No new packages"
          end
        end

        describe 'syncing packages in progress' do
          let(:fixture_variant) { :progress_packages }

          specify do
            action.humanized_output.must_equal "New packages: 20/32 (48 KB/76.7 KB)"
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
end
