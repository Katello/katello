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
    module System
      class GenerateApplicability < Actions::Base

        def plan(systems)
          plan_action(Pulp::Consumer::GenerateApplicability, :uuids => systems.map(&:uuid))
          plan_self(:system_ids => systems.map(&:id))
        end

        def finalize
          ::User.current = ::User.anonymous_admin
          systems = ::Katello::System.where(:id => input[:system_ids])
          systems.each do |system|
            system.import_applicability
          end
        ensure
          ::User.current = nil
        end

      end
    end
  end
end
