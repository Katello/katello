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
  module Candlepin
    module Consumer
      class Update < Candlepin::Abstract
        def plan(system)
          plan_self(:uuid => system.uuid,
                    :facts => system.facts,
                    :guestIds => system.guestIds,
                    :installedProducts => system.installedProducts,
                    :autoheal => system.autoheal,
                    :releaseVer => system.releaseVer,
                    :serviceLevel => system.serviceLevel,
                    :cp_environment_id => system.cp_environment_id,
                    :capabilities => system.capabilities,
                    :lastCheckin => system.lastCheckin)
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.update(input[:uuid],
                                                           input[:facts],
                                                           input[:guestIds],
                                                           input[:installedProducts],
                                                           input[:autoheal],
                                                           input[:releaseVer],
                                                           input[:serviceLevel],
                                                           input[:cp_environment_id],
                                                           input[:capabilities],
                                                           input[:lastCheckin])
        end
      end
    end
  end
end
