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
    module CapsuleContent
      class FeaturesRefreshed < ::Actions::EntryAction
        def plan(smart_proxy, old_features, new_features)
          capsule = ::Katello::CapsuleContent.new(smart_proxy)

          if new_features.map(&:name).include?(SmartProxy::PULP_NODE_FEATURE)
            plan_action(Pulp::Consumer::ActivateNode, capsule.consumer)
          elsif (old_features - new_features).map(&:name).include?(SmartProxy::PULP_NODE_FEATURE)
            plan_action(Pulp::Consumer::DeactivateNode, capsule.consumer)
          end
        end
      end
    end
  end
end
