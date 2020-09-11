module Actions
  module Pulp3
    module ContentGuard
      class RefreshAllDistributions < Pulp3::Abstract
        def plan(smart_proxy)
          sequence do
            plan_action(Actions::Pulp3::ContentGuard::Refresh, smart_proxy)

            roots = ::Katello::RootRepository.where.not(:content_type => ::Katello::Repository::DOCKER_TYPE).where(:unprotected => false)
            repositories = ::Katello::Repository.where(:root => roots)
            if repositories.any?
              plan_action(::Actions::BulkAction, Actions::Pulp3::Repository::RefreshDistribution, repositories, smart_proxy.id, assume_content_guard_exists: true)
            end
          end
        end
      end
    end
  end
end
