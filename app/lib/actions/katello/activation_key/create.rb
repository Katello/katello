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
      class Create < Actions::EntryAction
        def plan(activation_key)
          activation_key.disable_auto_reindex!
          activation_key.save!
          if ::Katello.config.use_cp
            cp_create = plan_action(Candlepin::ActivationKey::Create,
                                    organization_label: activation_key.organization.label,
                                    auto_attach: activation_key.auto_attach)
            cp_id = cp_create.output[:response][:id]
          end
          action_subject(activation_key, :cp_id => cp_id)
          plan_self
          plan_action ElasticSearch::Reindex, activation_key if ::Katello.config.use_elasticsearch
        end

        def humanized_name
          _("Create")
        end

        def finalize
          activation_key = ::Katello::ActivationKey.find(input[:activation_key][:id])
          activation_key.disable_auto_reindex!
          activation_key.cp_id = input[:cp_id]
          activation_key.save!
        end
      end
    end
  end
end
