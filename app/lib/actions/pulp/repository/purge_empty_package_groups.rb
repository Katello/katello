module Actions
  module Pulp
    module Repository
      class PurgeEmptyPackageGroups < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id, Integer
        end

        def invoke_external_task
          repo = ::Katello::Repository.where(:pulp_id => input[:pulp_id]).first

          package_lists = repo.package_lists_for_publish
          rpm_names = package_lists[:names]

          # Remove all  package groups with no packages
          package_groups_to_delete = repo.package_groups.collect do |group|
            group.package_group_id if rpm_names.intersection(group.package_names).empty?
          end
          package_groups_to_delete.compact!

          repo.unassociate_by_filter(::Katello::ContentViewPackageGroupFilter::CONTENT_TYPE,
                                   "id" => { "$in" => package_groups_to_delete })
        end
      end
    end
  end
end
