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
      class Destroy < Actions::EntryAction

        def plan(repository)
          action_subject(repository)
          repository.destroy
        end

        def humanized_name
          _("Delete")
        end

        def cli_example
          if task_input[:organization].nil? ||
                task_input[:product].nil? ||
                task_input[:repository].nil?
            return ""
          end
        <<-EXAMPLE
katello repo delete --org '#{task_input[:organization][:name]}'\\
                    --product '#{task_input[:product][:name]}'\\
                    --name '#{task_input[:repository][:name]}'
        EXAMPLE
        end

      end
    end
  end
end
