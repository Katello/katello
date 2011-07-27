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

require "spec_helper"

describe Api::ProxiesController do
  describe "routing" do

    it {{ :get => "/api/consumers" }.should route_to(:controller => "api/systems", :action => "index")}
    it {{ :get => "/api/consumers/1" }.should route_to(:controller => "api/systems", :action => "show", :id => "1")}
    it {{ :post => "/api/consumers" }.should route_to(:controller => "api/systems", :action => "create")}
    it {{ :post => "/api/consumers/1" }.should route_to(:controller => "api/systems", :action => "regenerate_identity_certificates", :id => "1")}
    it {{ :delete => "/api/consumers/1" }.should route_to(:controller => "api/systems", :action => "destroy", :id => "1")}

    it {{ :get => "/api/consumers/1/certificates/" }.should route_to(:controller => "api/candlepin_proxies", :action => "get", :id => "1")}
    it {{ :get => "/api/consumers/1/certificates/serials" }.should route_to(:controller => "api/candlepin_proxies", :action => "get", :id => "1")}
    it {{ :get => "/api/consumers/1/entitlements" }.should route_to(:controller => "api/candlepin_proxies", :action => "get", :id => "1")}
    it {{ :post => "/api/consumers/1/entitlements" }.should route_to(:controller => "api/candlepin_proxies", :action => "post", :id => "1")}
    it {{ :delete => "/api/consumers/1/entitlements" }.should route_to(:controller => "api/candlepin_proxies", :action => "delete", :id => "1")}
    it {{ :delete => "/api/consumers/1/certificates/1" }.should route_to(:controller => "api/candlepin_proxies", :action => "delete", :consumer_id => "1", :id => "1")}
    it {{ :get => "/api/pools" }.should route_to(:controller => "api/candlepin_proxies", :action => "get")}
    it {{ :get => "/api/products" }.should route_to(:controller => "api/candlepin_proxies", :action => "get")}
    it {{ :get => "/api/entitlements/1" }.should route_to(:controller => "api/candlepin_proxies", :action => "get", :id => "1")}
    it {{ :post => "/api/subscriptions" }.should route_to(:controller => "api/candlepin_proxies", :action => "post")}
    
    it {{ :put => "/api/consumers/1/profile/" }.should route_to(:controller => "api/systems", :action => "upload_package_profile", :id => "1")}

  end
end
