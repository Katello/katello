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

module Katello
describe Api::V1::TasksController do
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include OrganizationHelperMethods

  before(:each) do
    setup_controller_defaults_api

    disable_product_orchestration
    disable_user_orchestration

    @organization = new_test_org
    @controller.stubs(:get_organization).returns(@organization)
    @provider = Provider.create!(:provider_type => Provider::CUSTOM, :name => "foo1", :organization => @organization)
    Provider.stubs(:find).returns(@provider)

    Organization.stubs(:find_by_label).returns(@organization)

    @task = mock()
    @task.stubs(:organization).returns(@organization)
    @task.stubs(:to_json).returns({})
    @task.stubs(:refresh).returns({})
    @task.stubs(:user).returns({})
    TaskStatus.stubs(:find_by_uuid!).returns(@task)
  end

  context "get a listing of tasks" do
    let(:action) { :index }
    let(:req) { get :index, :organization_id => @organization.id }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"

    it "should retrieve all async tasks in the organization" do
      Glue::ElasticSearch::Items.any_instance.expects(:retrieve).returns([[@task], 1])
      req
    end
  end

  context "get a specific task" do
    let(:action) { :show }
    let(:req) { get :show, :id => '1' }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"

    it "should retrieve task specified by uuid" do
      TaskStatus.expects(:find_by_uuid!).once.with('1').returns(@t)
      req
    end

    it "should refresh retrieved task" do
      @task.expects(:refresh).once.returns(@task)
      req
    end
  end

end
end