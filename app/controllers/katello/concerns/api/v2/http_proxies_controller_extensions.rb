module Katello
  module Concerns
    module Api
      module V2
        module HttpProxiesControllerExtensions
          module ApiPieExtensions
            extend ::Apipie::DSL::Concern

            update_api(:create) do
              param :http_proxy, Hash do
                param :default_content_proxy, :bool, :required => false, :desc => N_('Set this proxy as the default content proxy')
              end
            end
          end
        end
      end
    end
  end
end
