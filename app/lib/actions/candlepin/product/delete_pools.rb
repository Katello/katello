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
      class DeletePools < Candlepin::Abstract
        input_format do
          param :organization_label
          param :cp_id
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.pools(input[:organization_label], input[:cp_id]).each do |pool|
            ::Katello::Pool.find_all_by_cp_id(pool['id']).each(&:destroy)
            ::Katello::Resources::Candlepin::Pool.destroy(pool['id'])
          end
        end
      end
    end
  end
end
