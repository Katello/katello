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

module Orchestrate
  module Katello
    class SystemPackageRemove < Orchestrate::Action

      include Helpers::Lock
      include Helpers::PulpPackagesPresenter

      def plan(system, packages)
        lock(system)
        plan_action(Pulp::ConsumerContentUninstall,
                    consumer_uuid: system.uuid,
                    type: 'rpm',
                    args: packages)
      end

      def humanized_name
        _("Remove package")
      end

      # Used by PulpPackagesPresenter to find the details about the task
      def pulp_subaction
        Pulp::ConsumerContentUninstall
      end


    end
  end
end
