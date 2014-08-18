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
      class UpdateImporter < Pulp::Abstract

        input_format do
          param :repo_id
          param :id
          param :config
        end

        def run
          output[:response] = ::Katello.pulp_server.extensions.repository.
              update_importer(*input.values_at(:repo_id, :id, :config))
        end

      end
    end
  end
end
