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
  space = ::Actions::Katello::Repository

  describe space do
    include Dynflow::Testing

    describe 'Create' do
      it 'plans' do
        # TODO remove this mocking when action is broken down
        cp           = mock 'cp', update_cp_content: nil
        organization = mock 'organization', default_content_view: cp, library: nil
        product      = mock 'product', organization: organization
        repository   = mock 'repository',
                            save!:             true,
                            product:           product,
                            generate_metadata: nil
        action_class = space::Create

        action = create_action action_class
        action.stubs :action_subject
        plan_action action, repository
      end
    end

    describe 'Destroy' do
      it 'plans' do
        action_class = space::Destroy
        repository   = mock 'repository', destroy: true
        action       = create_action action_class
        action.stubs :action_subject
        plan_action action, repository
      end
    end

    describe 'Discover' do
      it 'plans' do
        action_class = space::Discover
        action       = create_and_plan_action action_class, url = 'http://'
        assert_action_run_planned action
      end

      it 'runs' do
        action_class   = space::Discover
        action_planned = create_and_plan_action action_class, url = 'http://'

        ::Katello::RepoDiscovery.
            expects(:new).
            returns(mock('discovery', run: nil))

        run_action action_planned
      end
    end

    describe 'Sync' do
      it 'plans' do
        action_class = space::Sync
        repository   = mock 'repository', pulp_id: 1
        action       = create_action action_class
        action.stubs :action_subject
        plan_action action, repository

        assert_action_plan_planned action, ::Actions::Pulp::Repository::Sync
      end
    end
  end
end
