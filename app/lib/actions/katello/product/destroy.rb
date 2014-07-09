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
    module Product
      class Destroy < Actions::EntryAction

        # rubocop:disable MethodLength
        def plan(product)

          unless product.user_deletable?
            fail _("Cannot delete a Red Hat Products or Products with Repositories published in a Content View")
          end

          no_other_assignment = ::Katello::Product.where(["cp_id = ? AND id != ?", product.cp_id, product.id]).count == 0
          product.disable_auto_reindex!
          action_subject(product)

          sequence do
            concurrence do
              product.repositories.in_default_view.each do |repo|
                plan_action(Katello::Repository::Destroy, repo)
              end
            end
            concurrence do
              plan_action(Candlepin::Product::DeletePools,
                            cp_id: product.cp_id, organization_label: product.organization.label)
              plan_action(Candlepin::Product::DeleteSubscriptions,
                            cp_id: product.cp_id, organization_label: product.organization.label)
            end

            if no_other_assignment
              if product.is_a? ::Katello::MarketingProduct
                concurrence do
                  product.productContent.each do |pc|
                    plan_action(Candlepin::Product::ContentRemove,
                                product_id: product.cp_id,
                                content_id: pc.content.id)
                  end
                end
              end

              plan_action(Candlepin::Product::Destroy, cp_id: product.cp_id)
            end

            product.reload.destroy!
            plan_action(ElasticSearch::Reindex, product)
          end
        end

        def humanized_name
          _("Delete Product")
        end
      end
    end
  end
end
