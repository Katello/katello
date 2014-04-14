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
    module Consumer
      class Create < Candlepin::Abstract
        input_format do
          param :cp_environment_id
          param :organization_label
          param :name
          param :cp_type
          param :facts
          param :installed_products
          param :autoheal
          param :release_ver
          param :service_level
          param :uuid
          param :capabilities
          param :activation_keys
        end

        def run
          output[:response] = ::Katello::Resources::Candlepin::Consumer.
              create(input[:cp_environment_id],
                     input[:organization_label],
                     input[:name],
                     input[:cp_type],
                     input[:facts],
                     input[:installed_products],
                     input[:autoheal],
                     input[:release_ver],
                     input[:service_level],
                     input[:uuid],
                     input[:capabilities],
                     input[:activation_keys])
        end
      end
    end
  end
end
