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

  describe ::Actions::Headpin::System do
    include Dynflow::Testing
    include Support::Actions::RemoteAction
    include FactoryGirl::Syntax::Methods

    describe "Create" do
      let(:action_class) { ::Actions::Headpin::System::Create }
      let(:action) { create_action action_class }

      let(:system) do
        env = build(:k_t_environment,
                    :library,
                    organization: build(:organization, :acme_corporation))
        build(:system, :alabama, environment: env)
      end

      it 'plans' do
        stub_remote_user
        system.expects(:save!)
        action.stubs(:action_subject).with do |subject, params|
          subject.must_equal(system)
          params[:uuid].must_be_kind_of Dynflow::ExecutionPlan::OutputReference
          params[:uuid].subkeys.must_equal %w[response uuid]
        end
        plan_action(action, system)
        assert_action_planed(action, ::Actions::Candlepin::Consumer::Create)
        assert_action_planed_with action, ::Actions::ElasticSearch::Reindex, system
      end

      it 'updates the uuid in finalize method' do
        System.stubs(:find).with(123).returns(system)
        action.input[:remote_user] = 'user'
        action.input[:system] = { id:  123 }
        action.input[:uuid] = '123'
        system.expects(:save!)
        finalize_action action
        system.uuid.must_equal '123'
      end
    end
  end
end
