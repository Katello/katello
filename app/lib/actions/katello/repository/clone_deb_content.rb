module Actions
  module Katello
    module Repository
      class CloneDebContent < Actions::Base
        # rubocop:disable MethodLength
        def plan(source_repo, target_repo, filters, _purge_empty_units, options = {})
          generate_metadata = options.fetch(:generate_metadata, true)
          index_content = options.fetch(:index_content, true)

          copy_clauses = nil
          remove_clauses = nil
          filters = filters.deb unless filters.is_a? Array

          if filters.any?
            clause_gen = ::Katello::Util::PackageClauseGenerator.new(source_repo, filters)
            clause_gen.generate
            copy_clauses = clause_gen.copy_clause
            remove_clauses = clause_gen.remove_clause
          end

          sequence do
            if filters.empty? || copy_clauses
              plan_copy(Pulp::Repository::CopyDeb, source_repo, target_repo, copy_clauses)
            elsif options[:simple_clone]
              plan_copy(Pulp::Repository::CopyDeb, source_repo, target_repo)
            end
            if remove_clauses
              plan_remove(Pulp::Repository::RemoveDeb, target_repo, :unit => remove_clauses)
            end
            plan_copy(Pulp::Repository::CopyDebRelease, source_repo, target_repo)
            plan_copy(Pulp::Repository::CopyDebComponent, source_repo, target_repo)

            # Check for matching content before indexing happens, the content in pulp is
            # actually updated, but it is not reflected in the database yet.
            output = {}
            if target_repo.environment && !options[:force_yum_metadata_regeneration]
              output = plan_action(Katello::Repository::CheckMatchingContent,
                                   :source_repo_id => source_repo.id,
                                   :target_repo_id => target_repo.id).output
            end

            plan_action(Katello::Repository::IndexContent, id: target_repo.id) if index_content

            source_repository = filters.empty? ? source_repo : nil

            if generate_metadata
              plan_action(Katello::Repository::MetadataGenerate,
                          target_repo,
                          :source_repository => source_repository,
                          :matching_content => output[:matching_content])
            end
          end
        end

        def plan_copy(action_class, source_repo, target_repo, clauses = nil)
          plan_action(action_class,
                      source_pulp_id: source_repo.pulp_id,
                      target_pulp_id: target_repo.pulp_id,
                      clauses:        clauses)
        end

        def plan_remove(action_class, target_repo, clauses)
          plan_action(action_class,
                      pulp_id:        target_repo.pulp_id,
                      clauses:        clauses)
        end
      end
    end
  end
end
