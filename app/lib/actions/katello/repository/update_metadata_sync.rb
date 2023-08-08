module Actions
  module Katello
    module Repository
      class UpdateMetadataSync < Actions::Base
        def plan(repository)
          sequence do
            plan_action(Katello::Repository::MetadataGenerate, repository)
            concurrence do
              (::SmartProxy.unscoped.with_repo(repository).select { |sp| sp.authorized?(:manage_capsule_content) && sp.authorized?(:view_capsule_content) })&.each do |capsule|
                next if capsule.pulp_primary?
                plan_action(Katello::CapsuleContent::Sync, capsule, repository_id: repository.id)
              end
            end
          end
        end
      end
    end
  end
end
