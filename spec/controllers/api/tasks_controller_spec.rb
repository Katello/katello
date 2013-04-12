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

require 'spec_helper.rb'

describe Api::TasksController do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include OrganizationHelperMethods

  before(:each) do
    login_user_api

    disable_product_orchestration
    disable_user_orchestration

    @organization = new_test_org
    @controller.stub!(:get_organization).and_return(@organization)
    @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
    Provider.stub!(:find).and_return(@provider)

    @task = mock(TaskStatus)
    @task.stub(:organization).and_return(@organization)
    @task.stub(:to_json).and_return({})
    @task.stub(:refresh).and_return({})
    @task.stub(:user).and_return({})
    TaskStatus.stub(:where).and_return(@task)
    TaskStatus.stub!(:find_by_uuid!).and_return(@task)
  end

  context "get a listing of tasks" do
    let(:action) {:index}
    let(:req) { get :index, :organization_id => @organization.id }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"

    it "should retrieve all async tasks in the organization" do
      TaskStatus.should_receive(:where).once.with(:organization => @organization).and_return([])
      req
    end
  end

  context "get a specific task" do
    let(:action) {:show}
    let(:req) { get :show, :id => '1' }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"

    it "should retrieve task specified by uuid" do
      TaskStatus.should_receive(:find_by_uuid!).once.with('1').and_return(@t)
      req
    end

    it "should refresh retrieved task" do
      @task.should_receive(:refresh).once.and_return(@task)
      req
    end
  end

end
