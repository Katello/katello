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
          # need to check if candlepin attributes have changed prior to updating attributes
          update_candlepin = update_candlepin?(activation_key, activation_key_params)
          activation_key.disable_auto_reindex!
          action_subject activation_key
          activation_key.update_attributes!(activation_key_params)
          if update_candlepin
            plan_action(::Actions::Candlepin::ActivationKey::Update,
                        cp_id: activation_key.cp_id,
                        release_version: activation_key.release_version,
                        service_level: activation_key.service_level,
                        auto_attach: activation_key.auto_attach)
          end
        end

        def update_candlepin?(activation_key, activation_key_params)
          cp_changed?(activation_key.auto_attach, activation_key_params[:auto_attach]) ||
          cp_changed?(activation_key.service_level, activation_key_params[:service_level]) ||
          cp_changed?(activation_key.release_version, activation_key_params[:release_version])
        end

        def cp_changed?(activation_key, activation_key_params)
          !activation_key_params.nil? && activation_key.to_s != activation_key_params.to_s
        end
      end
    end
  end
end
