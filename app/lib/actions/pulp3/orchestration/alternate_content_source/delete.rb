module Actions
  module Pulp3
    module Orchestration
      module AlternateContentSource
        class Delete < Pulp3::Abstract
          def plan(smart_proxy_acs, options = {})
            sequence do
              plan_action(Actions::Pulp3::AlternateContentSource::Delete, smart_proxy_acs)
              plan_action(Actions::Pulp3::AlternateContentSource::DeleteRemote, smart_proxy_acs, **options)
              plan_self(smart_proxy_id: smart_proxy_acs.smart_proxy_id, smart_proxy_acs_id: smart_proxy_acs.id)
            end
          end

          def finalize
            smart_proxy_acs_id = input[:smart_proxy_acs_id]
            ::Katello::SmartProxyAlternateContentSource.find_by(id: smart_proxy_acs_id).destroy
          end
        end
      end
    end
  end
end
