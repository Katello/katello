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
describe Api::V1::SyncPlansController do
  include AuthorizationHelperMethods

  before(:each) do
    setup_controller_defaults_api
    @request.env["HTTP_ACCEPT"] = "application/json"
    disable_org_orchestration

    @organization = Organization.create! do |o|
      o.name  = "org-1234"
      o.label = "org-1234"
    end
  end
  describe "create" do
    let(:request_params) {
      { :organization_id => @organization.label,
        :sync_plan       =>
            { :name        => "Foo",
              :description => "This is the key string",
              :sync_date   => Time.now,
              :interval    => "daily"
            }
      }.with_indifferent_access
    }

    describe "invalid create params" do
      let(:req) do
        bad_req                       = request_params
        bad_req[:sync_plan][:bad_foo] = "mwahaha"
        post :create, bad_req
      end
      it_should_behave_like "bad request"
    end

    it "should be successful" do
      post :create, request_params
      must_respond_with(:success)
      SyncPlan.first.wont_be_nil
      SyncPlan.first.name.must_equal request_params[:sync_plan][:name]
    end
  end

  describe "update" do
    let(:sync_plan) { SyncPlan.create!(:name     => "foo", :sync_date => Time.now, :description => "foo",
                                       :interval => "daily", :organization => @organization) }
    let(:request_params) {
      { :id              => sync_plan.id,
        :organization_id => @organization.label,
        :sync_plan       =>
            { :name        => sync_plan.name + "--Altered",
              :description => "#{sync_plan.description} --Altered",
              :sync_date   => Time.now
            }
      }.with_indifferent_access
    }

    describe "invalid create params" do
      let(:req) do
        bad_req                       = request_params
        bad_req[:sync_plan][:bad_foo] = "mwahaha"
        put :update, bad_req
      end
      it_should_behave_like "bad request"
    end

    it "should be successful" do
      put :update, request_params
      must_respond_with(:success)
      SyncPlan.first.name.must_equal request_params[:sync_plan][:name]
    end
  end
end
end
