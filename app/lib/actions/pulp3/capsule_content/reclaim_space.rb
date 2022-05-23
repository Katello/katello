module Actions
  module Pulp3
    module CapsuleContent
      class ReclaimSpace < Pulp3::AbstractAsyncTask
        def plan(smart_proxy)
          if smart_proxy.pulp_primary?
            repository_hrefs = ::Katello::Pulp3::RepositoryReference.default_cv_repository_hrefs(::Katello::Repository.unscoped.on_demand, ::Organization.all)
            repository_hrefs.flatten!
          else
            if smart_proxy.download_policy != ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
              fail _('Only On Demand smart proxies may have space reclaimed.')
            end
            repository_hrefs = ::Katello::Pulp3::Api::Core.new(smart_proxy).core_repositories_list_all(fields: 'pulp_href').map(&:pulp_href)
          end
          fail _('There is no downloaded content to clean.') if repository_hrefs.empty?
          plan_self(repository_hrefs: repository_hrefs, smart_proxy_id: smart_proxy.id)
        end

        def invoke_external_task
          output[:pulp_tasks] = ::Katello::Pulp3::Api::Core.new(SmartProxy.find(input[:smart_proxy_id])).
            repositories_reclaim_space_api.reclaim(repo_hrefs: input[:repository_hrefs])
        end
      end
    end
  end
end
