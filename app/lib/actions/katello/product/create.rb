# Copyright 2013 Red Hat, Inc.
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
    module Product

      class Create < Actions::EntryAction

        # @param [Katello::Product] product
        # @param [Katello::Provider] provider
        # @param [Katello::Organization] organization
        def plan(product, provider, organization)

          product.disable_auto_reindex!
          product.provider = provider

          if product.provider.nil?
            create_anonymous = plan_action ::Actions::Katello::Provider::CreateAnonymous, organization
            product.provider = create_anonymous.output[:response]
          end

          plan_action ::Actions::Candlepin::Provider::SetProduct, product.name, product.multiplier || 1, product.attrs

          if product.provider && product.provider.yum_repo?
            plan_action ::Actions::Candlepin::Provider::SetUnlimitedSubscription, organization.label, product.cp_id
          end

          product.save!
          action_subject product
          plan_action ElasticSearch::Reindex, product
        end

        def humanized_name
          _("Create")
        end

      end

    end
  end
end
