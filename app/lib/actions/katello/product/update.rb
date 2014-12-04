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
      class Update < Actions::EntryAction
        def plan(product, product_params)
          product.disable_auto_reindex!
          action_subject product
          product.update_attributes!(product_params)
          if product.previous_changes.key?('gpg_key_id')
            plan_action(::Actions::Katello::Product::RepositoriesGpgReset, product)
          end

          if ::Katello.config.use_cp && product.productContent_changed?
            plan_action(::Actions::Candlepin::Product::Update, product)
          end
          plan_action(::Actions::Pulp::Repos::Update, product) if ::Katello.config.use_pulp
          plan_action(ElasticSearch::Reindex, product) if ::Katello.config.use_elasticsearch
        end
      end
    end
  end
end
