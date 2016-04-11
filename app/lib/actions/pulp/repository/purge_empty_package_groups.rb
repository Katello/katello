module Actions
  module Pulp
    module Repository
      class PurgeEmptyPackageGroups < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id, Integer
        end

        def invoke_external_task
          repo = ::Katello::Repository.where(:pulp_id => input[:pulp_id]).first
          rpm_names = repo.rpms.pluck(:name).uniq

          # Remove all  package groups with no packages
          package_groups_to_delete = repo.package_groups.select do |group|
            (rpm_names & group.package_names).empty?
          end
          criteria = {:association => {"unit_id" => {"$in" => package_groups_to_delete.compact}}}

          ::Katello.pulp_server.extensions.repository.unassociate_units(repo.pulp_id, :filters => criteria)
        end
      end
    end
  end
end
