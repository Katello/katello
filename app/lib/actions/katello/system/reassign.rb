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
      class Reassign < Actions::Base
        def plan(system, content_view_id, environment_id)
          system.content_view_id = content_view_id
          system.environment_id = environment_id

          if system.foreman_host
            cve = ::Katello::ContentViewPuppetEnvironment.in_content_view(content_view_id).in_environment(environment_id).first
            if cve && cve.puppet_environment
              system.foreman_host.environment = cve.puppet_environment
              system.foreman_host.save!
            end

          end
          system.save!
          plan_action(::Actions::Candlepin::Consumer::Update, system)
        end
      end
    end
  end
end
