module Actions
  module Pulp3
    module Repository
      class SaveDistributionReferences < Pulp3::Abstract
        def plan(repository, smart_proxy, tasks, options = {})
          # TODO: This docker-only reference reconciliation may become relevant for
          # all content types; see the matching TODO in Pulp3::Repository::Docker#refresh_distributions.
          distribution_href = if repository.docker? && smart_proxy.pulp_primary?
                                repository.backend_service(smart_proxy).distribution_reference&.href
                              end
          plan_self(repository_id: repository.id, smart_proxy_id: smart_proxy.id, tasks: tasks,
                    contents_changed: options[:contents_changed], distribution_href: distribution_href,
                    existing_only: options[:existing_only])
        end

        def run
          repo = ::Katello::Repository.find(input[:repository_id])
          return run_docker(repo) if repo.docker?

          if input[:tasks] && input[:tasks][:pulp_tasks] && input[:tasks][:pulp_tasks].first
            distribution_hrefs = input[:tasks][:pulp_tasks].map { |task| task[:created_resources].first }
            distribution_hrefs.compact!
            if distribution_hrefs.any?
              repo.backend_service(smart_proxy).save_distribution_references(distribution_hrefs)
            else
              repo.backend_service(smart_proxy).update_distribution
            end
          end
        end

        private

        def run_docker(repo)
          return unless smart_proxy.pulp_primary?

          service = repo.backend_service(smart_proxy)
          hrefs = docker_distribution_hrefs(service)
          service.save_distribution_references(hrefs) if hrefs.any?
        end

        def docker_distribution_hrefs(service)
          hrefs = if input[:existing_only]
                    []
                  else
                    tasks = input.dig(:tasks, :pulp_tasks) || []
                    tasks.filter_map { |task| task[:created_resources]&.first }
                  end
          return hrefs if hrefs.any?

          href = input[:distribution_href]
          href && service.distribution_reference&.href == href ? [href] : []
        end
      end
    end
  end
end
