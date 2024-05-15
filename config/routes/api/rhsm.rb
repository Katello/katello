class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Katello::Engine.routes.draw do
  scope :module => :api do
    match '/rhsm' => 'v2/root#rhsm_resource_list', :via => :get

    scope :path => :rhsm, :module => :rhsm, :as => :rhsm do
      # subscription-manager support
      scope :constraints => Katello::Api::Constraints::RegisterWithActivationKeyConstraint.new do
        match '/consumers' => 'candlepin_proxies#consumer_activate', :via => :post
      end
      match '/consumers' => 'candlepin_proxies#consumer_create', :via => :post
      match '/hypervisors' => 'candlepin_proxies#hypervisors_update', :via => :post
      match '/hypervisors/:owner/' => 'candlepin_proxies#async_hypervisors_update', :via => :post
      match '/hypervisors/:owner/heartbeat' => 'candlepin_proxies#hypervisors_heartbeat', :via => :put
      match '/owners/:organization_id/environments' => 'candlepin_proxies#rhsm_index', :via => :get
      match '/owners/:organization_id/pools' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_pools_path
      match '/owners/:organization_id/servicelevels' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_servicelevels_path
      match '/owners/:organization_id/system_purpose' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_system_purpose_path
      match '/environments/:environment_id/consumers' => 'candlepin_proxies#consumer_create', :via => :post
      match '/consumers/:id' => 'candlepin_proxies#consumer_show', :via => :get
      match '/consumers/:id' => 'candlepin_proxies#regenerate_identity_certificates', :via => :post
      match '/consumers/:id' => 'candlepin_proxies#consumer_destroy', :via => :delete
      match '/users/:login/owners' => 'candlepin_proxies#list_owners', :via => :get, :constraints => {:login => /\S+/}
      match '/consumers/:id/accessible_content' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_accessible_content_path
      match '/consumers/:id/certificates' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_certificates_path
      match '/consumers/:id/certificates' => 'candlepin_proxies#put', :via => :put, :as => :proxy_consumer_certificates_put_path
      match '/consumers/:id/release' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_releases_path
      match '/consumers/:id/compliance' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_compliance_path
      match '/consumers/:id/purpose_compliance' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_purpose_compliance_path
      match '/consumers/:id/certificates/serials' => 'candlepin_proxies#serials', :via => :get, :as => :proxy_certificate_serials_path
      match '/consumers/:id/entitlements' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_entitlements_path
      match '/consumers/:id/entitlements' => 'candlepin_proxies#post', :via => :post, :as => :proxy_consumer_entitlements_post_path
      match '/consumers/:id/entitlements' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_entitlements_delete_path
      match '/consumers/:id/entitlements/pool/:poolId' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_entitlements_pool_delete_path
      match '/consumers/:id/entitlements/dry-run' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_dryrun_path
      match '/consumers/:id/owner' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_owners_path
      match '/consumers/:consumer_id/certificates/:id' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_certificates_delete_path
      match '/consumers/:id/deletionrecord' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_deletionrecord_delete_path
      match '/pools' => 'candlepin_proxies#get', :via => :get, :as => :proxy_pools_path
      match '/deleted_consumers' => 'candlepin_proxies#get', :via => :get, :as => :proxy_deleted_consumers_path
      match '/entitlements/:id' => 'candlepin_proxies#get', :via => :get, :as => :proxy_entitlements_path
      match '/subscriptions' => 'candlepin_proxies#post', :via => :post, :as => :proxy_subscriptions_post_path
      match '/consumers/:id/profiles/' => 'candlepin_dynflow_proxy#upload_profiles', :via => :put
      match '/consumers/:id/profile/' => 'candlepin_dynflow_proxy#upload_package_profile', :via => :put
      match '/consumers/:id/packages/' => 'candlepin_dynflow_proxy#upload_package_profile', :via => :put
      match '/systems/:id/deb_package_profile' => 'candlepin_dynflow_proxy#deb_package_profile', :via => :put
      match '/consumers/:id/tracer/' => 'candlepin_proxies#upload_tracer_profile', :via => :put
      match '/consumers/:id/checkin/' => 'candlepin_proxies#checkin', :via => :put
      match '/consumers/:id' => 'candlepin_proxies#facts', :via => :put
      match '/consumers/:id/guestids/' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_guestids_path
      match '/consumers/:id/guestids/:guest_id' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_guestids_get_guestid_path
      match '/consumers/:id/guestids/' => 'candlepin_proxies#put', :via => :put, :as => :proxy_consumer_guestids_put_path
      match '/consumers/:id/guestids/:guest_id' => 'candlepin_proxies#put', :via => :put, :as => :proxy_consumer_guestids_put_guestid_path
      match '/consumers/:id/guestids/:guest_id' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_guestids_delete_guestid_path
      match '/consumers/:id/content_overrides/' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_content_overrides_path
      match '/consumers/:id/content_overrides/' => 'candlepin_proxies#put', :via => :put, :as => :proxy_consumer_content_overrides_put_path
      match '/consumers/:id/content_overrides/' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_content_overrides_delete_path
      match '/consumers/:id/available_releases' => 'candlepin_proxies#available_releases', :via => :get
      match '/systems/:id/enabled_repos' => 'candlepin_proxies#enabled_repos', :via => :put
      match '/jobs/:jobId' => 'candlepin_proxies#get', :via => :get, :as => :proxy_jobs_get_path
      match '/status' => 'candlepin_proxies#server_status', :via => :get
    end
  end
end
