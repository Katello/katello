module Actions
  module Pulp
    module Repository
      class PurgeEmptyErrata < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id, Integer
        end

        def invoke_external_task
          repo = ::Katello::Repository.where(:pulp_id => input[:pulp_id]).first

          package_lists = repo.package_lists_for_publish
          filenames = package_lists[:filenames]

          errata_to_delete = repo.errata.collect do |erratum|
            erratum.errata_id if filenames.intersection(erratum.packages.pluck(:filename)).empty?
          end
          errata_to_delete.compact!
          repo.unassociate_by_filter(::Katello::ContentViewErratumFilter::CONTENT_TYPE,
                                 "id" => { "$in" => errata_to_delete })
        end
      end
    end
  end
end
