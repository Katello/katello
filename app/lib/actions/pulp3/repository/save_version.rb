module Actions
  module Pulp3
    module Repository
      class SaveVersion < Pulp3::Abstract
        def plan(repository, options)
          plan_self(:repository_id => repository.id, :tasks => options[:tasks], :repository_details => options[:repository_details], :incremental_update => options[:incremental_update])
        end

        def run
          repo = ::Katello::Repository.find(input[:repository_id])

          if input[:tasks]
            version_href = input[:tasks].last[:created_resources].first
          end

          unless version_href
            if input[:repository_details]
              version_href = input[:repository_details][:latest_version_href]
            elsif input[:incremental_update]
              # Successive incremental updates won't generate a new repo version, so fetch the latest Pulp 3 repo version
              latest_version_href = ::Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_master!).
                repositories_api.read(repo.backend_service(SmartProxy.pulp_master).
                repository_reference.repository_href).latest_version_href
              repo.update(:version_href => latest_version_href)
            end
          end

          if version_href
            repo.update(:version_href => version_href)
            output[:contents_changed] = true
          else
            output[:contents_changed] = false
          end
        end
      end
    end
  end
end
