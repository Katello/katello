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
  module Pulp
    module Consumer
      class ActivateNode < Pulp::Abstract
        input_format do
          param :uuid, String
        end

        def plan(system)
          plan_self(:uuid => system.uuid, :display_name => system.name)
        end

        def run
          ::Katello.pulp_server.extensions.consumer.activate_node(input[:uuid], 'mirror')
        end
      end
    end
  end
end
