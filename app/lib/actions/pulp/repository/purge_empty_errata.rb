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
      class PurgeEmptyErrata < Pulp::AbstractAsyncTask

        input_format do
          param :pulp_id, Integer
        end

        def invoke_external_task
          repo = ::Katello::Repository.where(:pulp_id => input[:pulp_id]).first

          package_lists = repo.package_lists_for_publish
          filenames = package_lists[:filenames]

          errata_to_delete = repo.errata.collect do |erratum|
            erratum.errata_id if filenames.intersection(erratum.package_filenames).empty?
          end
          errata_to_delete.compact!
          repo.unassociate_by_filter(::Katello::ContentViewErratumFilter::CONTENT_TYPE,
                                { "id" => { "$in" => errata_to_delete } })

        end
      end
    end
  end
end
