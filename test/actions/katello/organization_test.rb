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

module ::Actions::Katello::Organization

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include Support::Actions::RemoteAction
    include FactoryGirl::Syntax::Methods

    let(:action) { create_action action_class }
  end

  class CreateTest < TestBase
    let(:action_class) { ::Actions::Katello::Organization::Create }
    let(:action) { create_action action_class }

    let(:organization) do
      build(:katello_organization, :acme_corporation, :with_library)
    end

    it 'plans' do
      provider = mock()
      organization.expects(:providers).returns([provider]).times(2)
      organization.expects(:save!)
      organization.expects(:disable_auto_reindex!).returns
      action.stubs(:action_subject).with(organization, any_parameters)
      plan_action(action, organization)
      assert_action_planed_with(action,
                                ::Actions::Candlepin::Owner::Create,
                                label:  organization.label,
                                name: organization.name)

      assert_action_planed_with(action,
                                ::Actions::Katello::Environment::LibraryCreate,
                                organization.library)

      assert_action_planed_with(action, ::Actions::ElasticSearch::Reindex, organization)

    end
  end
end
