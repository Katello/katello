module Actions
  module Katello
    module Repository
      class CloneDockerContent < Actions::Base
        def plan(source_repo, target_repo, filters)
          filters = filters.docker unless filters.is_a? Array

          if filters.any?
            clause_gen = ::Katello::Util::DockerManifestClauseGenerator.new(source_repo, filters)
            clause_gen.generate
            copy_clauses = clause_gen.copy_clause
          end

          sequence do
            if filters.empty? || copy_clauses
              plan_action(Pulp::Repository::CopyDockerTag, source_pulp_id: source_repo.pulp_id,
                          target_pulp_id: target_repo.pulp_id, clauses: copy_clauses)
            end
            plan_action(Katello::Repository::MetadataGenerate, target_repo)
            plan_action(Katello::Repository::IndexContent, id: target_repo.id)
          end
        end
      end
    end
  end
end
