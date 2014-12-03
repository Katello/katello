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
    module Foreman
      class HostUpdate < Actions::EntryAction
        input_format do
          param :system_id, Integer
          param :environment_id, Integer
        end

        def plan(system)
          if system.foreman_host &&
              system.foreman_host.environment.lifecycle_environment &&
              system.foreman_host.environment.content_view

            if puppet_env = system.content_view.puppet_env(system.environment).try(:puppet_environment)
              if puppet_env.id != system.foreman_host.environment_id
                plan_self(:system_id => system.id, :environment_id => puppet_env.id)
              end
            else
              fail Errors::NotFound,
                   _("Couldn't find puppet environment associated with lifecycle environment '%{env}' and content view '%{view}'") %
                       { :env => system.environment.name, :view => system.content_view.name }
            end
          end
        end

        def run
          system = ::Katello::System.find(input[:system_id])
          system.foreman_host.environment_id = input[:environment_id]
          system.foreman_host.save!
        end
      end
    end
  end
end
