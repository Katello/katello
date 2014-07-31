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
  module Foreman
    module Environment
      class Destroy < Actions::Base

        def plan(environment)
          if environment.hosts.count > 0
            names = environment.hosts.limit(5).pluck(:name).join(', ')
            fail _("The puppet environment %{name} is in use by %{count} Host(s) including %{names}") %
                     {:name => environment.name, :names => names, :count => environment.hosts.count}
          end

          if environment.hostgroups.count > 0
            names = environment.hostgroups.limit(5).pluck(:name).join(', ')
            fail _("The puppet environment %{name} is in use by %{count} Host Group(s) including %{names}") %
                     {:name => environment.name, :names => names, :count => environment.hostgroups.count}
          end

          environment.destroy!
        end

      end
    end
  end
end
