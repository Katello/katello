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
      class ContentDestroy < Actions::Base
        def plan(repository)
          if !repository.product.provider.redhat_provider? &&
               repository.other_repos_with_same_product_and_content.empty?
            sequence do
              plan_action(Candlepin::Product::ContentRemove,
                          product_id: repository.product.cp_id,
                          content_id: repository.content_id)
              if repository.other_repos_with_same_content.empty?
                plan_action(Candlepin::Product::ContentDestroy,
                            content_id: repository.content_id)
              end
            end
          end
        end
      end
    end
  end
end
