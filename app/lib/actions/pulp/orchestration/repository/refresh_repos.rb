module Actions
  module Pulp
    module Orchestration
      module Repository
        class RefreshRepos < Pulp::AbstractAsyncTask
          include ::Actions::Katello::CapsuleContent::RefreshRepos
          input_format do
            param :smart_proxy_id
            param :environment_id
            param :content_view_id
            param :repository_id
          end

          def fetch_proxy_service(smart_proxy)
            ::Katello::Pulp::SmartProxyRepository.new(smart_proxy)
          end

          def act_on_repo?(repo, smart_proxy)
            !smart_proxy.pulp3_support?(repo)
          end
        end
      end
    end
  end
end
