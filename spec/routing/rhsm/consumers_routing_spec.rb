#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv1) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv1 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "katello_test_helper"

module Katello
  describe Api::Rhsm::CandlepinProxiesController do
    before do
      setup_engine_routes
    end

    describe "routing" do
      let(:proxies_controller) { "katello/api/rhsm/candlepin_proxies" }

      it "should route to the correct controller actions" do
        {:controller => proxies_controller, :action => "consumer_show", :id => "1"}.must_recognize(:method => "get", :path => "/rhsm/consumers/1")
        {:controller => proxies_controller, :action => "consumer_create", :environment_id => "Library"}.must_recognize(:method => "post", :path => "/rhsm/environments/Library/consumers")
        {:controller => proxies_controller, :action => "regenerate_identity_certificates", :id => "1"}.must_recognize(:method => "post", :path => "/rhsm/consumers/1")
        {:controller => proxies_controller, :action => "consumer_destroy", :id => "1"}.must_recognize(:method => "delete", :path => "/rhsm/consumers/1")
        ({:controller => proxies_controller, :action => "get", :id => "1"}).must_recognize(:method => "get", :path => "/rhsm/consumers/1/certificates")
        ({:controller => proxies_controller, :action => "get", :id => "1"}).must_recognize(:method => "get", :path => "/rhsm/consumers/1/certificates/serials")
        ({:controller => proxies_controller, :action => "get", :id => "1"}).must_recognize(:method => "get", :path => "/rhsm/consumers/1/entitlements")
        ({:controller => proxies_controller, :action => "post", :id => "1"}).must_recognize(:method => "post", :path => "/rhsm/consumers/1/entitlements")
        ({:controller => proxies_controller, :action => "delete", :id => "1"}).must_recognize(:method => "delete", :path => "/rhsm/consumers/1/entitlements")
        ({:controller => proxies_controller, :action => "delete", :consumer_id => "1", :id => "1"}).must_recognize(:method => "delete", :path => "/rhsm/consumers/1/certificates/1")
        ({:controller => proxies_controller, :action => "get"}).must_recognize(:method => "get", :path => "/rhsm/pools")
        ({:controller => proxies_controller, :action => "get", :id => "1"}).must_recognize(:method => "get", :path => "/rhsm/entitlements/1")
        ({:controller => proxies_controller, :action => "post"}).must_recognize(:method => "post", :path => "/rhsm/subscriptions")
        {:controller => proxies_controller, :action => "upload_package_profile", :id => "1"}.must_recognize(:method => "put", :path => "/rhsm/consumers/1/profile/")
        {:controller => proxies_controller, :action => "get", :id => "1"}.must_recognize(:method => "get", :path => "/rhsm/consumers/1/guestids/")
        {:controller => proxies_controller, :action => "get", :id => "1", :guest_id => "1"}.must_recognize(:method => "get", :path => "/rhsm/consumers/1/guestids/1")
        {:controller => proxies_controller, :action => "put", :id => "1"}.must_recognize(:method => "put", :path => "/rhsm/consumers/1/guestids/")
        {:controller => proxies_controller, :action => "put", :id => "1", :guest_id => "1"}.must_recognize(:method => "put", :path => "/rhsm/consumers/1/guestids/1")
        {:controller => proxies_controller, :action => "delete", :id => "1", :guest_id => "1"}.must_recognize(:method => "delete", :path => "/rhsm/consumers/1/guestids/1")
        {:controller => proxies_controller, :action => "get", :id => "1"}.must_recognize(:method => "get", :path => "/rhsm/consumers/1/content_overrides/")
        {:controller => proxies_controller, :action => "put", :id => "1"}.must_recognize(:method => "put", :path => "/rhsm/consumers/1/content_overrides/")
        {:controller => proxies_controller, :action => "delete", :id => "1"}.must_recognize(:method => "delete", :path => "/rhsm/consumers/1/content_overrides/")
        {:controller => proxies_controller, :action => "available_releases", :id => "1"}.must_recognize(:method => "get", :path => "/rhsm/consumers/1/available_releases")
      end
    end
  end
end
