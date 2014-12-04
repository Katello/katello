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
  module Pulp
    module Repository
      class CreateInPlan < Create
        alias_method :perform_run, :run

        def plan(input)
          plan_self(input)
          pulp_extensions.repository.create_with_importer_and_distributors(input[:pulp_id],
                                                                                      importer,
                                                                                      distributors,
                                                                                      display_name: input[:name])
        rescue => e
          raise error_message(e.http_body) || e
        end

        def error_message(body)
          JSON.parse(body)['error_message']
        rescue JSON::ParserError
          nil
        end

        def run
          self.output = input
        end
      end
    end
  end
end
