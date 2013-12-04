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

require "katello_test_helper"

module Katello
describe Api::V2::ChangesetsController do
  before do
    setup_engine_routes
  end
  describe "routing" do

    let(:cs_controller) { "katello/api/v1/changesets" }

    it "should route correctly" do
      {:method => :get, :path => "/api/changesets/1" }.must_route_to({:controller => cs_controller, :action => "show", :id => "1", :api_version => "v1"})
      {:method => :put, :path => "/api/changesets/1" }.must_route_to({:controller => cs_controller, :action => "update", :id => "1", :api_version => "v1"})
      {:method => :delete, :path => "/api/changesets/1" }.must_route_to({:controller => cs_controller, :action => "destroy", :id => "1", :api_version => "v1"})
      {:method => :post, :path => "/api/changesets/1/apply" }.must_route_to({:controller => cs_controller, :action => "apply", :id => "1", :api_version => "v1"})
    end

  end
end
end
