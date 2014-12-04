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
  module ElasticSearch
    module Repository
      class Destroy < ElasticSearch::Abstract
        input_format do
          param :pulp_id, Integer
        end

        def run
          indexed_package_ids = ::Katello::Package.indexed_ids_for_repo(pulp_id)
          indexed_puppet_module_ids = ::Katello::PuppetModule.indexed_ids_for_repo(pulp_id)

          ::Katello::Package.remove_indexed_repoid(indexed_package_ids, pulp_id)
          ::Katello::PuppetModule.remove_indexed_repoid(indexed_puppet_module_ids, pulp_id)
        end

        def pulp_id
          self.input[:pulp_id]
        end
      end
    end
  end
end
