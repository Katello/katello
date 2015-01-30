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
    module ActivationKey
      class Update < Candlepin::Abstract
        input_format do
          param :cp_id
          param :release_version
          param :service_level
          param :auto_attach
        end

        def run
          ::Katello::Resources::Candlepin::ActivationKey.update(
                                                                input[:cp_id],
                                                                input[:release_version],
                                                                input[:service_level],
                                                                input[:auto_attach])
        end
      end
    end
  end
end
