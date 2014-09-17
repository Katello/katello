
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
  module Candlepin
    module Product
      class Update < Candlepin::Abstract

        def plan(product)
          product.deleted_content.each do |product_content|
            plan_action(::Actions::Candlepin::Product::ContentRemove,
                        :product_id => product.cp_id,
                        :content_id => product_content.content.id)
            plan_action(::Actions::Candlepin::Product::ContentDestroy,
                        :content_id => product_content.content.id)
          end

          product.added_content.each do |pc|
            content_create = plan_action(::Actions::Candlepin::Product::ContentCreate,
                                         :name => pc.content.name,
                                         :type => pc.content.type,
                                         :label => pc.content.label,
                                         :content_url => pc.content.contentUrl)
            plan_action(::Actions::Candlepin::Product::ContentAdd,
                        :product_id => product.cp_id,
                        :content_id => content_create.output[:response][:id])
          end
        end

      end
    end
  end
end
