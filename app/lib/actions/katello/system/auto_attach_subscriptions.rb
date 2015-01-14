#
# Copyright 2015 Red Hat, Inc.
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
      class AutoAttachSubscriptions < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system)
          system.disable_auto_reindex!
          action_subject system
          plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, system) if ::Katello.config.use_cp
          plan_action(ElasticSearch::Reindex, system) if ::Katello.config.use_elasticsearch
        end
      end
    end
  end
end
