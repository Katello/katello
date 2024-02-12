module Actions
  module Katello
    module Repository
      class CopyDebErratum < Actions::Base
        input_format do
          param :source_repo_id
          param :target_repo_id
          param :erratum_ids
          param :clean_target_errata
        end

        def run
          target_repo = ::Katello::Repository.find(input[:target_repo_id])

          # drop all existing errata from target_repo (e.g. promoting LCENV back to an earlier version)
          target_repo.repository_errata.destroy_all if input[:clean_target_errata] == true

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
            units = []
            ::Katello::Erratum.find(erratum_ids_to_copy).each do |erratum|
              units << { 'type_id' => 'erratum', 'unit_key' => { 'id' => erratum.pulp_id } }
              erratum.deb_packages.map do |pkg|
                units << { 'type_id' => 'deb', 'unit_key' => { 'name' => pkg.name, 'version' => pkg.version } }
              end
            end
            output[:pulp_tasks] = [{ :result => { :units_successful => units } }]
          end
        end
      end
    end
  end
end
