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
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, sys_params)
          system.disable_auto_reindex!
          action_subject system
          system.update_attributes!(sys_params)
          sequence do
            concurrence do
              plan_action(::Actions::Pulp::Consumer::Update, system) if !system.hypervisor? && ::Katello.config.use_pulp
              plan_action(::Actions::Candlepin::Consumer::Update, system) if ::Katello.config.use_cp
            end

            if sys_params[:autoheal] && ::Katello.config.use_cp
              plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, system)
            end
            plan_action(ElasticSearch::Reindex, system) if ::Katello.config.use_elasticsearch
          end
        end
      end
    end
  end
end
