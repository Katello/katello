module Actions
  module Pulp3
    module ContentGuard
      class RefreshAllDistributions < Pulp3::Abstract
        def plan(smart_proxy)
          sequence do
            plan_action(Actions::Pulp3::ContentGuard::Refresh, smart_proxy)

            protected_types = [::Katello::Repository::YUM_TYPE, ::Katello::Repository::FILE_TYPE, ::Katello::Repository::DEB_TYPE]
            roots = ::Katello::RootRepository.where(:content_type => protected_types).where(:unprotected => false)
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
