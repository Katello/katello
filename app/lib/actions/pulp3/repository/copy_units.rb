module Actions
  module Pulp3
    module Repository
      class CopyUnits < Pulp3::AbstractAsyncTask
        def plan(source_repo, target_repo, units, dest_base_version, options = {})
          if units.any?
            unit_map = { :errata => [], :rpms => []}
            units.each do |unit|
              if unit.class.name == "Katello::Erratum"
                unit_map[:errata] << unit.id
              elsif unit.class.name == "Katello::Rpm"
                unit_map[:rpms] << unit.id
              end
            end
            action_output = plan_self(source_repo_id: source_repo.id,
                      target_repo_id: target_repo.id,
                      unit_map: unit_map,
                      dest_base_version: dest_base_version,
                      dependency_solving: options[:dependency_solving],
                      incremental_update: options[:incremental_update],
                      smart_proxy_id: SmartProxy.pulp_master.id).output
            plan_action(Pulp3::Repository::SaveVersion, target_repo, tasks: action_output[:pulp_tasks], incremental_update: options[:incremental_update]).output
          end
        end

        def invoke_external_task
          unit_hrefs = []
          source_repo = ::Katello::Repository.find(input[:source_repo_id])
          target_repo = ::Katello::Repository.find(input[:target_repo_id])

          if input[:unit_map][:errata].any?
            unit_hrefs << ::Katello::RepositoryErratum.
              joins("inner join katello_errata on katello_repository_errata.erratum_id = katello_errata.id").
              where("katello_repository_errata.repository_id = #{source_repo.id} and
                    katello_errata.id in (#{input[:unit_map][:errata].join(",")})").map(&:erratum_pulp3_href)
          end

          if input[:unit_map][:rpms].any?
            unit_hrefs << ::Katello::Rpm.where(:id => input[:unit_map][:rpms]).map(&:pulp_id)
          end

          dest_base_version = input[:dest_base_version]

          output[:pulp_tasks] = target_repo.backend_service(SmartProxy.pulp_master).copy_units(source_repo.version_href, unit_hrefs.flatten, input[:dependency_solving], dest_base_version)
        end
      end
    end
  end
end
