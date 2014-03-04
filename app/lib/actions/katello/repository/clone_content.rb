#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module Katello
    module Repository
      class CloneContent < Dynflow::Action

        def plan(source_repo, target_repo, filters)
          if target_repo.puppet?
            fail NotImplementedError
          else
            copy_clauses = nil
            remove_clauses = nil
            process_errata_and_groups = false
            filters = filters.yum unless filters.is_a? Array

            if filters.any?
              clause_gen = Util::PackageClauseGenerator.new(repo, filters)
              clause_gen.generate
              copy_clauses = clause_gen.copy_clause
              remove_clauses = clause_gen.remove_clause
            end

            sequence do
              if filters.empty? || copy_clauses
                plan_copy(Pulp::Repository::CopyRpm,
                          source_repo, target_repo, copy_clauses)
                process_errata_and_groups = true
              end
              if remove_clauses
                plan_remove(Pulp::Repository::RemoveRpm,
                            target_repo, remove_clauses)
                process_errata_and_groups = true
              end
              if process_errata_and_groups
                plan_copy(Pulp::Repository::CopyErrata,
                          source_repo, target_repo, copy_clauses)
                plan_copy(Pulp::Repository::CopyPackageGroup,
                          source_repo, target_repo, copy_clauses)
              end
              plan_copy(Pulp::Repository::CopyYumMetadataFile, source_repo, target_repo)
              plan_copy(Pulp::Repository::CopyDistribution, source_repo, target_repo)
              plan_action(Katello::Repository::MetadataGenerate,
                          target_repo,
                          filters.empty? ? source_repo : nil)
              concurrence do
                # TODO: we need to do this only for non_archive repos
                plan_action(Katello::Repository::NodeMetadataGenerate,
                            target_repo)
                # TODO: we need to do this only for non_archive repos
                plan_action(Pulp::Repository::RegenerateApplicability,
                            pulp_id: target_repo.pulp_id)
                plan_action(Katello::Repository::Reindex, target_repo)
              end
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
