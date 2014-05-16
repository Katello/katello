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
        def plan(product, organization)
          product.disable_auto_reindex!
          product.provider = organization.anonymous_provider
          product.organization = organization

          cp_create = plan_action(::Actions::Candlepin::Product::Create,
                                  :name => product.name,
                                  :multiplier => 1,
                                  :attributes => [{:name => "arch", :value => "ALL"}])

          cp_id = cp_create.output[:response][:id]

          plan_action(::Actions::Candlepin::Product::CreateUnlimitedSubscription,
                      :owner_key => organization.label,
                      :product_id => cp_id)
          product.save!
          action_subject product, :cp_id => cp_id

          plan_self
          plan_action ElasticSearch::Reindex, product
        end

        def finalize
          product = ::Katello::Product.find(input[:product][:id])
          product.disable_auto_reindex!
          product.cp_id = input[:cp_id]
          product.save!
        end

        def humanized_name
          _("Create")
        end

      end

    end
  end
end
