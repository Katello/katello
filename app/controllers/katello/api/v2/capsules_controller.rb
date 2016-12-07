module Katello
  class Api::V2::CapsulesController < ::Api::V2::SmartProxiesController
    resource_description do
      api_base_url "/katello/api"
    end

    api :GET, '/capsules', 'List all smart proxies that have content'
    param_group :search, Api::V2::ApiController
    def index
      @smart_proxies = SmartProxy.with_content.authorized(:view_smart_proxies).includes(:features).
                search_for(*search_options).paginate(paginate_options)
      @total = SmartProxy.with_content.authorized(:view_smart_proxies).includes(:features).count
    end

    api :GET, '/capsules/:id', 'Show the smart proxy details'
    param :id, Integer, :desc => 'Id of the smart proxy', :required => true
    def show
      super
    end

    def resource_name
      :smart_proxy
    end

    protected

    def resource_class
      SmartProxy
    end

    def authorized
      User.current.allowed_to?(params.slice(:action, :id).merge(controller: 'api/v2/smart_proxies'))
    end
  end
end
