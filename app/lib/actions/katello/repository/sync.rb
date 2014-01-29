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
      class Sync < Actions::EntryAction

        include Helpers::RemoteAction

        # TODO: in Rails 4.0, the logic is possible to use from ActiveSupport
        include ActionView::Helpers::NumberHelper

        input_format do
          param :id, Integer
        end

        def plan(repo)
          action_subject(repo)
          plan_action(Pulp::Repository::Sync, pulp_id: repo.pulp_id)
        end

        def finalize
          repo = ::Katello::Repository.find(input[:repository][:id])
          repo.index_content
        end

        def humanized_name
          _("Synchronize")
        end

        def details_action
          all_actions.find { |action| action.is_a? ::Actions::Pulp::Repository::Sync }
        end

        def humanized_output
          pulp_task = details_action && details_action.output[:pulp_task]
          return unless pulp_task
          ret = []
          if details = (pulp_task[:result] && pulp_task[:result][:details] ||
                        pulp_task[:progress] && pulp_task[:progress][:yum_importer])
            ret.concat(humanized_details(details))
          end
          ret.join("\n")
        end

        def humanized_details(details)
          ret = []
          if (content = details[:content]) && content[:state] != 'NOT_STARTED'
            if content[:items_total].to_i > 0
              if content[:state] == "IN_PROGRESS"
                count_done = content[:items_total] - content[:items_left]
                count = "#{count_done}/#{content[:items_total]}"
                size_done = content[:size_total] - content[:size_left]
                size = "#{number_to_human_size(size_done)}/#{number_to_human_size(content[:size_total].to_i)}"
              else
                count = content[:items_total]
                size = number_to_human_size(content[:size_total].to_i)
              end
              ret << (_("New packages: %s (%s)") % [count, size])
            else
              ret << _("No new packages")
            end
          end
          if (metadata = details[:metadata]) && metadata[:state] == 'IN_PROGRESS'
            ret << _("Processing metadata")
          end
          return ret
        end

      end
    end
  end
end
