module Actions
  module Katello
    module Repository
      class CloneYumContent < Actions::Base
        # rubocop:disable MethodLength
        def plan(source_repo, target_repo, filters, purge_empty_units, options = {})
          generate_metadata = options.fetch(:generate_metadata, true)
          index_content = options.fetch(:index_content, true)

          copy_clauses = nil
          remove_clauses = nil
          process_errata_and_groups = false
          filters = filters.yum unless filters.is_a? Array

          if filters.any?
            clause_gen = ::Katello::Util::PackageClauseGenerator.new(source_repo, filters)
            clause_gen.generate
            copy_clauses = clause_gen.copy_clause
            remove_clauses = clause_gen.remove_clause
          end

          sequence do
            if filters.empty? || copy_clauses
              plan_copy(Pulp::Repository::CopyRpm, source_repo, target_repo, copy_clauses)
              process_errata_and_groups = true
            elsif options[:simple_clone]
              plan_copy(Pulp::Repository::CopyRpm, source_repo, target_repo)
              process_errata_and_groups = true
            end
            if remove_clauses
              plan_remove(Pulp::Repository::RemoveRpm, target_repo, :unit => remove_clauses)
              process_errata_and_groups = true
            end
            if process_errata_and_groups
              plan_copy(Pulp::Repository::CopyErrata, source_repo, target_repo, nil)
              plan_copy(Pulp::Repository::CopyPackageGroup, source_repo, target_repo, nil)
            end
            plan_copy(Pulp::Repository::CopyYumMetadataFile, source_repo, target_repo)
            plan_copy(Pulp::Repository::CopyDistribution, source_repo, target_repo)

            if purge_empty_units
              plan_action(Katello::Repository::IndexErrata, target_repo)
              plan_action(Pulp::Repository::PurgeEmptyErrata, :pulp_id => target_repo.pulp_id)
              plan_action(Katello::Repository::IndexPackageGroups, target_repo)
              plan_action(Pulp::Repository::PurgeEmptyPackageGroups, :pulp_id => target_repo.pulp_id)
            end

            plan_action(Katello::Repository::MetadataGenerate, target_repo, filters.empty? ? source_repo : nil) if generate_metadata
            plan_action(Katello::Repository::IndexContent, id: target_repo.id) if index_content
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
