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

require "katello_test_helper"

module Katello
describe Api::V1::ProxiesController do
  before do
    @routes = Katello::Engine.routes
  end

  describe "routing" do

    let(:systems_controller) { "katello/api/v1/systems" }
    let(:proxies_controller) { "katello/api/v1/candlepin_proxies" }

    it "should route to the correct controller actions" do
      {:controller => systems_controller, :action => "index"}.must_recognize({ :method => "get", :path => "/api/consumers" })
      {:controller => systems_controller, :action => "show", :id => "1"}.must_recognize({ :method => "get", :path => "/api/consumers/1" })
      {:controller => systems_controller, :action => "create"}.must_recognize({ :method => "post", :path => "/api/consumers" })
      {:controller => systems_controller, :action => "regenerate_identity_certificates", :id => "1"}.must_recognize({ :method => "post", :path => "/api/consumers/1" })
      {:controller => systems_controller, :action => "destroy", :id => "1"}.must_recognize({ :method => "delete", :path => "/api/consumers/1" })

      ({:controller => proxies_controller, :action => "get", :id => "1"}).must_recognize({ :method => "get", :path => "/api/consumers/1/certificates" })
      ({:controller => proxies_controller, :action => "get", :id => "1"}).must_recognize({ :method => "get", :path => "/api/consumers/1/certificates/serials" })
      ({:controller => proxies_controller, :action => "get", :id => "1"}).must_recognize({ :method => "get", :path => "/api/consumers/1/entitlements" })
      ({:controller => proxies_controller, :action => "post", :id => "1"}).must_recognize({ :method => "post", :path => "/api/consumers/1/entitlements" })
      ({:controller => proxies_controller, :action => "delete", :id => "1"}).must_recognize({ :method => "delete", :path => "/api/consumers/1/entitlements" })
      ({:controller => proxies_controller, :action => "delete", :consumer_id => "1", :id => "1"}).must_recognize({ :method => "delete", :path => "/api/consumers/1/certificates/1" })
      ({:controller => proxies_controller, :action => "get"}).must_recognize({ :method => "get", :path => "/api/pools" })
      ({:controller => proxies_controller, :action => "get", :id => "1"}).must_recognize({ :method => "get", :path => "/api/entitlements/1" })
      ({:controller => proxies_controller, :action => "post"}).must_recognize({ :method => "post", :path => "/api/subscriptions" })

      {:controller => systems_controller, :action => "upload_package_profile", :id => "1"}.must_recognize({ :method => "put", :path => "/api/consumers/1/profile/" })
    end

  end
end
end
