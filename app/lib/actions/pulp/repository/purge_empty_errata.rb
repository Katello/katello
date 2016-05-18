module Actions
  module Pulp
    module Repository
      class PurgeEmptyErrata < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id, Integer
        end

        def invoke_external_task
          repo = ::Katello::Repository.where(:pulp_id => input[:pulp_id]).first
          errata_to_delete = repo.empty_errata

          repo.unassociate_by_filter(::Katello::ContentViewErratumFilter::CONTENT_TYPE,
                                 "id" => { "$in" => errata_to_delete.map(&:errata_id) })
        end
      end
    end
  end
end
