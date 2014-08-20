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
  module Katello
    module Repository
      class FinishUpload < Actions::Base

        def plan(repository, dependency = nil)
          unless repository.puppet?
            plan_action(Katello::Repository::MetadataGenerate, repository, nil, dependency)
          end

          recent_range = 5.minutes.ago.iso8601
          plan_action(ElasticSearch::Repository::FilteredIndexContent,
                      id: repository.id,
                      filter: {:association => {:created => {"$gt" => recent_range}}},
                      dependency: dependency)
        end

      end
    end
  end
end
