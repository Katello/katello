module Actions
  module Pulp
    module Repository
      class Refresh < Pulp::Abstract
        input_format do
          param :capsule_id
        end

        def plan(repository, input = {})
          input[:capsule_id] ||= SmartProxy.default_capsule!.id
          repository_details = pulp_extensions(input[:capsule_id]).repository.retrieve_with_details(repository.pulp_id)
          update_or_associate_importer(input[:capsule_id], repository, repository_details)
          update_or_associate_distributors(input[:capsule_id], repository, repository_details)
          remove_unnecessary_distributors(input[:capsule_id], repository, repository_details)
        end

        def update_or_associate_importer(capsule_id, repository, repository_details)
          existing_importers = repository_details["importers"]
          importer = repository.generate_importer(::SmartProxy.find_by(:id => capsule_id))
          found = existing_importers.find { |i| i['importer_type_id'] == importer.id }

          if found
            plan_action(::Actions::Pulp::Repository::UpdateImporter,
                        :repo_id => repository.pulp_id,
                        :id => found['id'],
                        :config => importer.config,
                        :capsule_id => capsule_id
                       )
          else
            plan_action(::Actions::Pulp::Repository::AssociateImporter,
                        :repo_id => repository.pulp_id,
                        :type_id => repository.importers.first['importer_type_id'],
                        :config => importer.config,
                        :capsule_id => capsule_id,
                        :hash => { :importer_id => importer.id }
                       )
          end
        end

        def update_or_associate_distributors(capsule_id, repository, repository_details)
          concurrence do
            existing_distributors = repository_details["distributors"]
            capsule = capsule_id ? SmartProxy.find(capsule_id) : nil
            repository.generate_distributors(capsule).each do |distributor|
              found = existing_distributors.find { |i| i['distributor_type_id'] == distributor.type_id }
              if found
                plan_action(::Actions::Pulp::Repository::RefreshDistributor,
                            :repo_id => repository.pulp_id,
                            :id => found['id'],
                            :config => distributor.config,
                            :capsule_id => capsule_id
                           )
              else
                plan_action(::Actions::Pulp::Repository::AssociateDistributor,
                            :repo_id => repository.pulp_id,
                            :type_id => distributor.type_id,
                            :config => distributor.config,
                            :capsule_id => capsule_id,
                            :hash => { :distributor_id => distributor.id }
                           )
              end
            end
          end
        end

        def remove_unnecessary_distributors(capsule_id, repository, repository_details)
          concurrence do
            existing_distributors = repository_details["distributors"]
            capsule = capsule_id ? SmartProxy.find(capsule_id) : nil
            generated_distributors = repository.generate_distributors(capsule)
            existing_distributors.each do |distributor|
              found = generated_distributors.find { |dist| dist.type_id == distributor['distributor_type_id'] }
              unless found
                plan_action(Pulp::Repository::DeleteDistributor, :repo_id => repository.pulp_id,
                                                                 :distributor_id => distributor['id'],
                                                                 :capsule_id => capsule_id
                           )
              end
            end
          end
        end
      end
    end
  end
end
