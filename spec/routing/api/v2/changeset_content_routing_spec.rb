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
describe Api::V2::ChangesetsContentController do
  before do
    @routes = Katello::Engine.routes
  end
  describe "routing" do

    let(:cs_content_controller) { "katello/api/v1/changesets_content" }

    it "should route to the correct controller actions" do
      { :method => :post, :path => "/api/changesets/1/products" }.must_route_to({:controller => cs_content_controller, :action => "add_product", :changeset_id => "1"})
      { :method => :delete, :path => "/api/changesets/1/products/2" }.must_route_to({:controller => cs_content_controller, :action => "remove_product", :changeset_id => "1", :id => "2"})

      { :method => :post, :path => "/api/changesets/1/packages" }.must_route_to({:controller => cs_content_controller, :action => "add_package", :changeset_id => "1"})
      { :method => :delete, :path => "/api/changesets/1/packages/2" }.must_route_to({:controller => cs_content_controller, :action => "remove_package", :changeset_id => "1", :id => "2"})

      { :method => :post, :path => "/api/changesets/1/errata" }.must_route_to({:controller => cs_content_controller, :action => "add_erratum", :changeset_id => "1"})
      { :method => :delete, :path => "/api/changesets/1/errata/2" }.must_route_to({:controller => cs_content_controller, :action => "remove_erratum", :changeset_id => "1", :id => "2"})

      { :method => :post, :path => "/api/changesets/1/repositories" }.must_route_to({:controller => cs_content_controller, :action => "add_repo", :changeset_id => "1"})
      { :method => :delete, :path => "/api/changesets/1/repositories/2" }.must_route_to({:controller => cs_content_controller, :action => "remove_repo", :changeset_id => "1", :id => "2"})

      { :method => :post, :path => "/api/changesets/1/distributions" }.must_route_to({:controller => cs_content_controller, :action => "add_distribution", :changeset_id => "1"})
      { :method => :delete, :path => "/api/changesets/1/distributions/2" }.must_route_to({:controller => cs_content_controller, :action => "remove_distribution", :changeset_id => "1", :id => "2"})

      { :method => :post, :path => "/api/changesets/1/content_views" }.must_route_to({:controller => cs_content_controller, :action => "add_content_view", :changeset_id => "1"})
      { :method => :delete, :path => "/api/changesets/1/content_views/2" }.must_route_to({:controller => cs_content_controller, :action => "remove_content_view", :changeset_id => "1", :id => "2"})
    end

  end
end
end
