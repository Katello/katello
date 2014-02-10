#
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
  module Pulp
    module User
      class Create < Dynflow::Action

        include Helpers::RemoteAction

        input_format do
          param :remote_id, String
        end

        def run
          user_params = { name: input[:remote_id],
                          password: Password.generate_random_string(16) }
          output[:response] = pulp_resources.user.create(input[:remote_id], user_params)
        rescue RestClient::ExceptionWithResponse => e
          if e.http_code == 409
            Rails.logger.info "pulp user #{input[:remote_id]}: already exists. continuing"
          else
            raise e
          end
        end
      end
    end
  end
end
