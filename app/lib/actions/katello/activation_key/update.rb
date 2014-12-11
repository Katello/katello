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
    module ActivationKey
      class Update < Actions::EntryAction
        def plan(activation_key, activation_key_params)
          activation_key.disable_auto_reindex!
          activation_key.update_attributes!(activation_key_params)
          plan_action(::Actions::Candlepin::ActivationKey::Update,
                      cp_id: "activation_key.cp_id",
                      release_version: "activation_key.releaseVer",
                      service_level: "activation_key.serviceLevel",
                      auto_attach: "activation_key.autoAttach")
          action_subject activation_key
        end
      end
    end
  end
end
