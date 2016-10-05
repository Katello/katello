module Katello
  module Concerns
    module Api::V2::SmartProxiesControllerExtensions
      extend ActiveSupport::Concern

      included do
        def_param_group :smart_proxy do
          param :smart_proxy, Hash, :required => true, :action_aware => true do
            param :name, String, :required => true
            param :url, String, :required => true
            param :download_policy, String, :required => false, :desc => N_('Download Policy of the capsule, must be one of %s') %
                                      SmartProxy::DOWNLOAD_POLICIES.join(', ')
            param_group :taxonomies, ::Api::V2::BaseController
          end
        end

        api :POST, "/smart_proxies/", N_("Create a smart proxy")
        param_group :smart_proxy, :as => :create

        def create
          @smart_proxy = SmartProxy.new(smart_proxy_params)
          process_response @smart_proxy.save
        end

        api :PUT, "/smart_proxies/:id/", N_("Update a smart proxy")
        param :id, String, :required => true
        param_group :smart_proxy

        def update
          process_response @smart_proxy.update_attributes(smart_proxy_params)
        end
      end
    end
  end
end
