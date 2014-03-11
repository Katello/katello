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

    describe "Create" do
      let(:action_class) { ::Actions::Katello::Repository::Create }

      it 'plans' do
        # TODO remove this mocking when action is broken down
        cp           = mock 'cp', update_cp_content: nil
        organization = mock 'organization', default_content_view: cp, library: nil
        product      = mock 'product', organization: organization
        repository   = mock 'repository',
                            save!:             true,
                            product:           product,
                            generate_metadata: nil

        action = create_action action_class
        action.expects(:action_subject).with(repository)
        plan_action action, repository
      end
    end

    describe 'Destroy' do
      let(:action_class) { ::Actions::Katello::Repository::Destroy }

      it 'plans' do
        repository   = mock 'repository', destroy: true
        action       = create_action action_class
        action.stubs(:action_subject).with(repository)
        plan_action action, repository
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

      let :action do
        create_action(action_class).tap do |action|
          action.stubs(planned_actions: [pulp_action])
        end
      end
      let(:pulp_action) { fixture_action(pulp_action_class, output: fixture_variant) }

      it 'plans' do
        repository   = mock 'repository', pulp_id: 'pulp-repo-1', id: 1
        action       = create_action action_class
        action.stubs(:action_subject).with(repository)
        plan_action action, repository

        assert_action_planed_with action, pulp_action_class, pulp_id: 'pulp-repo-1'
        assert_action_planed_with action, ::Actions::ElasticSearch::Repository::IndexContent, id: 1
        assert_action_planed_with action, ::Actions::ElasticSearch::Reindex, repository
      end

      describe '#pulp_task_id' do
        let(:fixture_variant) { :success }

        specify { action.pulp_task_id.must_equal "f723b378-b535-41a7-8440-8ab7851fda10" }
      end

      describe 'progress' do
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
