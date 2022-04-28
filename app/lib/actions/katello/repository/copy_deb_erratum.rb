module Actions
  module Katello
    module Repository
      class CopyDebErratum < Actions::Base
        input_format do
          param :source_repo_id
          param :target_repo_id
          param :erratum_ids
        end

        def run
          target_repo = ::Katello::Repository.find(input[:target_repo_id])

          erratum_ids_to_copy = []
          if input[:source_repo_id].present?
            erratum_ids_to_copy = ::Katello::Repository.find(input[:source_repo_id])&.erratum_ids
          elsif input[:erratum_ids].present?
            erratum_ids_to_copy = ::Katello::Erratum.where(errata_id: input[:erratum_ids]).pluck(:id)
          end
          erratum_ids_to_copy -= target_repo.erratum_ids
          target_repo.erratum_ids |= erratum_ids_to_copy
          target_repo.save

          # fake output to make foreman task presenter happy
          if input[:erratum_ids].present?
            output[:pulp_tasks] = [{ :result => { :units_successful => ::Katello::Erratum.where(:id => erratum_ids_to_copy).pluck(:errata_id).map { |errata| { "type_id" => "erratum", "unit_key" => { id: errata } } } } }]
          end
        end
      end
    end
  end
end
