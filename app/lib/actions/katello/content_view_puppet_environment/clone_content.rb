module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class CloneContent < Actions::Base
        def plan(puppet_environment, module_ids_by_repoid)
          sequence do
            concurrence do
              module_ids_by_repoid.each_pair do |repo_id, module_ids|
                source_repo = ::Katello::ContentViewPuppetEnvironment.where(:pulp_id => repo_id).first ||
                  ::Katello::Repository.where(:pulp_id => repo_id).first
                plan_copy(Pulp::Repository::CopyPuppetModule, source_repo, puppet_environment, clauses(module_ids))
              end
            end

            plan_action(Pulp::ContentViewPuppetEnvironment::IndexContent, id: puppet_environment.id)
          end
        end

        def clauses(module_ids)
          { 'unit_id' => { "$in" => module_ids } }
        end

        def plan_copy(action_class, source_repo, target_repo, clauses = nil)
          plan_action(action_class,
                      source_pulp_id: source_repo.pulp_id,
                      target_pulp_id: target_repo.pulp_id,
                      clauses:        clauses)
        end
      end
    end
  end
end
