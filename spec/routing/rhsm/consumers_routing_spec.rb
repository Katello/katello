require "katello_test_helper"

module Katello
  describe Api::Rhsm::CandlepinProxiesController do
    before do
      setup_engine_routes
    end

    describe "routing" do
      let(:proxies_controller) { "katello/api/rhsm/candlepin_proxies" }
      let(:dynflow_proxy_controller) { "katello/api/rhsm/candlepin_dynflow_proxy" }

      it "should route to the correct controller actions" do
        {:controller => proxies_controller, :action => "consumer_show", :id => "1"}.must_recognize(:method => "get", :path => "/rhsm/consumers/1")
        {:controller => proxies_controller, :action => "consumer_create", :environment_id => "Library"}.must_recognize(:method => "post", :path => "/rhsm/environments/Library/consumers")
        {:controller => proxies_controller, :action => "regenerate_identity_certificates", :id => "1"}.must_recognize(:method => "post", :path => "/rhsm/consumers/1")
        {:controller => proxies_controller, :action => "consumer_destroy", :id => "1"}.must_recognize(:method => "delete", :path => "/rhsm/consumers/1")
        {:controller => proxies_controller, :action => "get", :id => "1"}.must_recognize(:method => "get", :path => "/rhsm/consumers/1/certificates")
        {:controller => proxies_controller, :action => "serials", :id => "1"}.must_recognize(:method => "get", :path => "/rhsm/consumers/1/certificates/serials")
        {:controller => proxies_controller, :action => "get", :id => "1"}.must_recognize(:method => "get", :path => "/rhsm/consumers/1/entitlements")
        {:controller => proxies_controller, :action => "post", :id => "1"}.must_recognize(:method => "post", :path => "/rhsm/consumers/1/entitlements")
        {:controller => proxies_controller, :action => "delete", :id => "1"}.must_recognize(:method => "delete", :path => "/rhsm/consumers/1/entitlements")
        {:controller => proxies_controller, :action => "delete", :consumer_id => "1", :id => "1"}.must_recognize(:method => "delete", :path => "/rhsm/consumers/1/certificates/1")
        {:controller => proxies_controller, :action => "get"}.must_recognize(:method => "get", :path => "/rhsm/pools")
        {:controller => proxies_controller, :action => "get", :id => "1"}.must_recognize(:method => "get", :path => "/rhsm/entitlements/1")
        {:controller => proxies_controller, :action => "post"}.must_recognize(:method => "post", :path => "/rhsm/subscriptions")
        {:controller => dynflow_proxy_controller, :action => "upload_package_profile", :id => "1"}.must_recognize(:method => "put", :path => "/rhsm/consumers/1/profile/")
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
