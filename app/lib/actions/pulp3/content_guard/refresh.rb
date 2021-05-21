module Actions
  module Pulp3
    module ContentGuard
      class Refresh < Pulp3::Abstract
        def plan(smart_proxy)
          plan_self(smart_proxy_id: smart_proxy.id)
        end

        def run
          ::Katello::Pulp3::Api::ContentGuard.new(smart_proxy).refresh
        end
      end
    end
  end
end
