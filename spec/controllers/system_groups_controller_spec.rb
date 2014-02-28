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
describe SystemGroupsController do

  include LocaleHelperMethods
  include OrganizationHelperMethods
  include OrchestrationHelper
  include AuthorizationHelperMethods

  describe "(katello)" do

  let(:uuid) { '1234' }
  before(:each) do
    setup_controller_defaults
    disable_org_orchestration
    disable_consumer_group_orchestration

    @controller.stubs(:search_validate).returns(true)
    @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
    @environment = create_environment(:name=>"DEV", :label=> "DEV", :prior=>@org.library, :organization=>@org)
    @org = @org.reload
    @controller.stubs(:current_organization).returns(@org)
  end

  describe "Controller tests " do
    before(:each) do
      @group = SystemGroup.create!(:name=>"test_group", :organization=>@org)
    end

    describe "GET index" do
      let(:action) {:index}
      let(:req) { get :index }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :system_groups, @group.id, @org) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "requests filters using search criteria" do
        get :index
        must_respond_with(:success)
      end
    end

  end
  end
end
end
