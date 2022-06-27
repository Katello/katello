module Actions
  module Katello
    module OrphanCleanup
      class RemoveOrphans < Actions::Base
        input_format do
          param :capsule_id
        end
        def plan(proxy)
          sequence do
            if proxy.pulp3_enabled?
              plan_action(
                Actions::Pulp3::Orchestration::OrphanCleanup::RemoveOrphans,
                proxy)
            end
            plan_self
          end
        end

        def run
          models = []
          ::Katello::RepositoryTypeManager.enabled_repository_types.each_value do |repo_type|
            indexable_types = repo_type.content_types_to_index
            models += indexable_types&.map(&:model_class)
            models.select! { |model| model.many_repository_associations }
          end
          models.each do |model|
            model.joins("left join katello_#{model.repository_association} on #{model.table_name}.id = katello_#{model.repository_association}.#{model.unit_id_field}").where("katello_#{model.repository_association}.#{model.unit_id_field} IS NULL").destroy_all
          end

          ::Katello::RootRepository.orphaned.destroy_all
        end
      end
    end
  end
end
