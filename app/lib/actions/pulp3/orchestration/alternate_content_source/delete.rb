module Actions
  module Pulp3
    module Orchestration
      module AlternateContentSource
        class Delete < Pulp3::Abstract
          def plan(acs, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::AlternateContentSource::Delete, acs, smart_proxy)
              plan_action(Actions::Pulp3::AlternateContentSource::DeleteRemote, acs, smart_proxy)
              plan_self(acs_id: acs.id, smart_proxy_id: smart_proxy.id)
            end
          end

          def finalize
            acs_id = input[:acs_id]
            smart_proxy_id = input[:smart_proxy_id]
            ::Katello::SmartProxyAlternateContentSource.find_by(alternate_content_source_id: acs_id, smart_proxy_id: smart_proxy_id).destroy
          end
        end
      end
    end
  end
end
