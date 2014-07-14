
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
      class Destroy < Actions::EntryAction

        def plan(activation_key, options = {})
          skip_candlepin = options.fetch(:skip_candlepin, false)
          action_subject(activation_key)

          plan_action(Candlepin::ActivationKey::Destroy, cp_id: activation_key.cp_id) unless skip_candlepin
          activation_key.destroy!
        end

        def humanized_name
          _("Delete Activation Key")
        end
      end
    end
  end
end
