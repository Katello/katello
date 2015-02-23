#
# Copyright 2015 Red Hat, Inc.
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
    module ContentView
      class Update < Actions::EntryAction
        def plan(content_view, content_view_params)
          content_view.disable_auto_reindex!
          content_view.disable_auto_reindex_on_association!
          repositories = repositories_to_reindex(content_view, content_view_params)

          action_subject content_view
          content_view.update_attributes!(content_view_params)

          if ::Katello.config.use_elasticsearch
            plan_action(ElasticSearch::Reindex, content_view)
            repositories.each { |repository| plan_action(ElasticSearch::ReindexOnAssociationChange, repository) }
          end
        end

        private

        def repositories_to_reindex(content_view, params)
          repoids = []
          if params["repository_ids"]
            repoids += (content_view.repository_ids - params["repository_ids"])
            repoids += (params["repository_ids"] - content_view.repository_ids)
          end
          ::Katello::Repository.where(:id => repoids)
        end
      end
    end
  end
end
