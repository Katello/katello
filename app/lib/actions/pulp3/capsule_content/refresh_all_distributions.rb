module Actions
  module Pulp3
    module CapsuleContent
      class RefreshAllDistributions < Pulp3::Abstract
        def plan(smart_proxy, repositories)
          concurrence do
            repositories.each do |repo|
              plan_action(RefreshDistribution, repo, smart_proxy)
            end
          end
        end
      end
    end
  end
end
