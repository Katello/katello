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
    module Environment
      class SetContent < Candlepin::Abstract
        input_format do
          param :cp_environment_id
          param :content_ids, Array
        end

        def run
          saved_cp_ids = ::Katello::Resources::Candlepin::Environment.
              find(input[:cp_environment_id])[:environmentContent].map do |content|
            content[:contentId]
          end
          add_ids    = input[:content_ids] - saved_cp_ids
          delete_ids = saved_cp_ids - input[:content_ids]

          output[:add_ids]         =    add_ids
          output[:add_response]    = ::Katello::Resources::Candlepin::Environment.
              add_content(input[:cp_environment_id], add_ids)

          output[:delete_ids]      = delete_ids
          output[:delete_response] = ::Katello::Resources::Candlepin::Environment.
              add_content(input[:cp_environment_id], delete_ids)
        end
      end
    end
  end
end
