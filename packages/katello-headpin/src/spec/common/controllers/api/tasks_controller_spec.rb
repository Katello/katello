#
# Copyright 2011 Red Hat, Inc.
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

  before(:each) do
    login_user_api

    @organization = Organization.new(:name => 'test') do |o|
      o.id = "123"
    end
    Organization.stub!(:first).and_return(@organization)
  end

  context "get a listing of tasks" do
    it "should retrieve all async tasks in the organization" do
      TaskStatus.should_receive(:where).once.with(:organization_id => @organization).and_return([])
      get :index, :organization_id => "123"
    end
  end

  context "get a specific task" do
    before(:each) do
      @t = TaskStatus.new

      TaskStatus.stub!(:find_by_uuid).and_return(@t)
      @t.stub!(:refresh).and_return({})
    end

    it "should retrieve task specified by uuid" do
      TaskStatus.should_receive(:find_by_uuid).once.with(1).and_return(@t)
      get :show, :id => 1
    end

    it "should refresh retrieved task" do
      @t.should_receive(:refresh).once.and_return(@t)
      get :show, :id => 1
    end
  end

end
