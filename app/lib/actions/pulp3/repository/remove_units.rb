module Actions
  module Pulp3
    module Repository
      class RemoveUnits < Pulp3::Abstract
        def plan(repository, smart_proxy, options)
          plan_self(repository_id: repository.id,
                    smart_proxy_id: smart_proxy.id,
                    options: options)
        end

        def run
          repo = ::Katello::Repository.find(input[:repository_id])
          content_units = ::Katello::FileUnit.find(input[:options][:content_unit_ids])
          output[:response] = repo.backend_service(smart_proxy).remove_content(content_units)
        end
      end
    end
  end
end
