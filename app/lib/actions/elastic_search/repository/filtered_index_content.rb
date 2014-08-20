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
      class FilteredIndexContent < ElasticSearch::Abstract

        input_format do
          param :id, Integer
          param :filter
          param :dependency
        end

        def run
          repo = ::Katello::Repository.find(input[:id])
          unit_ids = search_units(repo)
          if repo.puppet?
            ::Katello::PuppetModule.index_puppet_modules(unit_ids)
          else
            ::Katello::Package.index_packages(unit_ids)
          end
        end

        private

        def search_units(repo)
          found = repo.unit_search(:type_ids => [repo.unit_type_id],
                                   :filters => input[:filter])
          found.map { |result| result.try(:[], :unit_id) }.compact
        end
      end
    end
  end
end
