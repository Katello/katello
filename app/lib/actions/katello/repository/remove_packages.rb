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
    module Repository
      class RemovePackages < Actions::EntryAction
        def plan(repository, uuids)
          fail _("Cannot remove packages from a non-custom repository") if repository.redhat?
          fail _("Can only remove packages from within the Default Content View") unless repository.content_view.default?
          action_subject(repository)

          sequence do
            plan_action(Pulp::Repository::RemoveRpm, :pulp_id => repository.pulp_id,
                        :clauses => {:association => {'unit_id' => {'$in' => uuids}}
            })
            plan_action(ElasticSearch::Repository::RemovePackages, :pulp_id => repository.pulp_id, :uuids => uuids)
            plan_self(:repository_id => repository.id, :user_id => ::User.current.id)
          end
        end

        def resource_locks
          :link
        end

        def humanized_name
          _("Remove Packages")
        end

        def run
          ::User.current = ::User.find(input['user_id'])
          output[:task_id] = ForemanTasks.async_task(Actions::Katello::Repository::MetadataGenerate,
                                                     ::Katello::Repository.find(input['repository_id'])).id
        ensure
          ::User.current = nil
        end
      end
    end
  end
end
