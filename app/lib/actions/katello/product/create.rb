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
        def plan(product)
          product.disable_auto_reindex!

          if product.organization
            product.provider = product.organization.anonymous_provider
          end
          product.save!

          cp_create = plan_action(::Actions::Candlepin::Product::Create,
                                  :name => product.name,
                                  :multiplier => 1,
                                  :attributes => [{:name => "arch", :value => "ALL"}])

          cp_id = cp_create.output[:response][:id]

          plan_action(::Actions::Candlepin::Product::CreateUnlimitedSubscription,
                      :owner_key => product.organization.label,
                      :product_id => cp_id)

          action_subject product, :cp_id => cp_id

          plan_self(:user_id => ::User.current.id)
          plan_action ElasticSearch::Reindex, product
        end

        def finalize
          ::User.current = ::User.find(input[:user_id])
          product = ::Katello::Product.find(input[:product][:id])
          product.disable_auto_reindex!
          product.cp_id = input[:cp_id]
          product.save!
        ensure
          ::User.current = nil
        end

        def humanized_name
          _("Create")
        end

      end

    end
  end
end
