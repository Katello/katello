#
# Copyright 2014 Red Hat, Inc.
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
    module ContentViewVersion
      class IncrementalUpdate < Actions::EntryAction
        def humanized_name
          _("Incremental Update")
        end

        def plan(old_version, environments, content, dep_solve, description)
          action_subject(old_version.content_view)

          unless (environments - old_version.environments).empty?
            fail _("Content View Version %{id} not in all specified environments %{envs}") %
                     {:id => old_version.id, :envs => (environments - old_version.environments).map(&:name).join(',')}
          end

          new_minor = old_version.content_view.versions.where(:major => old_version.major).maximum(:minor) + 1
          new_version = old_version.content_view.create_new_version(description, old_version.major, new_minor)
          history = ::Katello::ContentViewHistory.create!(:content_view_version => new_version, :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS, :task => self.task)

          sequence do
            concurrence do
              old_version.archived_repos.each do |source_repo|
                sequence do
                  new_repo = plan_action(Repository::CloneToVersion, source_repo, new_version, true).new_repository

                  copy_yum_content(new_repo, dep_solve, content[:package_ids], content[:errata_ids])
                  plan_action(Katello::Repository::MetadataGenerate, new_repo, nil)
                  plan_action(ElasticSearch::Repository::IndexContent, id: new_repo.id)
                end
              end

              sequence do
                new_puppet_environment = plan_action(Katello::ContentViewPuppetEnvironment::Clone, old_version,
                                                   :new_version => new_version).new_puppet_environment
                copy_puppet_content(new_puppet_environment, content[:puppet_module_ids])
              end
            end

            plan_self(:content_view_id => old_version.content_view.id, :environment_ids => environments.map(&:id),
                      :user_id => ::User.current.id, :history_id => history.id)

          end
          promote(new_version, environments)
        end

        def finalize
          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        private

        def promote(new_version, environments)
          concurrence do
            environments.each do |environment|
              plan_action(Katello::ContentView::Promote, new_version, environment, true)
            end
          end
        end

        def copy_yum_content(new_repo, dep_solve, package_uuids, errata_uuids)
          if new_repo.content_type == ::Katello::Repository::YUM_TYPE
            unless errata_uuids.blank?
              plan_copy(Pulp::Repository::CopyErrata, new_repo.library_instance, new_repo,
                        { :filters => {:association => {'unit_id' => {'$in' => errata_uuids}}}},
                        :recursive => true, :resolve_dependencies => dep_solve)
            end

            unless package_uuids.blank?
              plan_copy(Pulp::Repository::CopyRpm, new_repo.library_instance, new_repo,
                        { :filters => {:association => {'unit_id' => {'$in' => package_uuids}}}},
                        resolve_dependencies => dep_solve)
            end
          end
        end

        def puppet_module_names(uuids)
          ::Katello::PuppetModule.id_search(uuids).map(&:name)
        end

        def remove_puppet_names(repo, names)
          plan_action(Pulp::Repository::RemovePuppetModule, :pulp_id => repo.pulp_id, :clauses => {:unit => {:name => {'$in' => names}}})
        end

        def copy_puppet_content(new_repo, puppet_module_uuids)
          unless puppet_module_uuids.blank?
            remove_puppet_names(new_repo, puppet_module_names(puppet_module_uuids))
            puppet_module_uuids.each { |uuid| copy_puppet_module(new_repo, uuid) }
          end
        end

        def copy_puppet_module(new_repo, uuid)
          possible_repos = ::Katello::PuppetModule.find(uuid).repositories.in_organization(new_repo.organization).in_default_view
          plan_action(Pulp::Repository::CopyPuppetModule, :source_pulp_id => possible_repos.first.pulp_id,
                    :target_pulp_id => new_repo.pulp_id, :clauses =>  {'unit_id' => uuid})
        end

        def plan_copy(action_class, source_repo, target_repo, clauses = nil, override_config = nil)
          plan_action(action_class,
                      :source_pulp_id => source_repo.pulp_id,
                      :target_pulp_id => target_repo.pulp_id,
                      :full_clauses => clauses,
                      :override_config => override_config)
        end
      end
    end
  end
end
