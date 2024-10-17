module Katello
  module Concerns
    module Api
      module V2
        module HttpProxiesControllerExtensions
          extend ::Apipie::DSL::Concern

          update_api(:create) do
            param :http_proxy, Hash do
              param :default_content_proxy, :bool, :required => false, :desc => N_('Set this HTTP proxy as the default content HTTP proxy')
            end
          end
        end
      end
    end
  end
end
