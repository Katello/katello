module Actions
  module Pulp
    module Repository
      class Refresh < Pulp::Abstract
        def plan(repository)
          plan_action(::Actions::Pulp::Repository::UpdateImporter,
                      :repo_id => repository.pulp_id,
                      :id => repository.importers.first['id'],
                      :config => repository.generate_importer.config
                      )
          existing_distributors = repository.distributors
          concurrence do
            repository.generate_distributors.each do |distributor|
              found = existing_distributors.find { |i| i['distributor_type_id'] == distributor.type_id }
              if found
                plan_action(::Actions::Pulp::Repository::RefreshDistributor,
                            :repo_id => repository.pulp_id,
                            :id => found['id'],
                            :config => distributor.config
                            )
              else
                plan_action(::Actions::Pulp::Repository::AssociateDistributor,
                            :repo_id => repository.pulp_id,
                            :type_id => distributor.type_id,
                            :config => distributor.config,
                            :hash => { :distributor_id => distributor.id }
                            )
              end
            end
          end
        end
      end
    end
  end
end
