module Actions
  module Pulp
    module Repository
      class CopyUnits < Pulp::AbstractAsyncTask
        def plan(source_repo, target_repo, units, options = {})
          if units.any?
            plan_self(source_repo_id: source_repo.id,
                      target_repo_id: target_repo.id,
                      class_name: units.first.class.name,
                      unit_ids: units.pluck(:id),
                      resolve_dependencies: options[:resolve_dependencies])
          end
        end

        def invoke_external_task
          source_repo = ::Katello::Repository.find(input[:source_repo_id])
          target_repo = ::Katello::Repository.find(input[:target_repo_id])

          units = input[:class_name].constantize.where(:id => input[:unit_ids])

          override_config = Katello::Repository.build_override_config(input)

          source_repo.backend_service(SmartProxy.pulp_master).copy_units(target_repo, units, override_config)
        end
      end
    end
  end
end
