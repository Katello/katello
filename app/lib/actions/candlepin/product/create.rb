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

      class SetProduct < Candlepin::Abstract

        input_format do
          param :name, String
          param :multiplier
          param :attributes
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.create(:name => input[:name],
                                                                              :multiplier => input[:multiplier],
                                                                              :attributes => input[:attributes])
        end

      end

      class SetUnlimitedSubscription < Candlepin::Abstract

        input_format do
          param :owner_key, String
          param :product_id, String
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Product.create_unlimited_subscription(input[:owner_key],
                                                                                                     input[:product_id])
        end
      end

    end
  end
end
