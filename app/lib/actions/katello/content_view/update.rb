module Actions
  module Katello
    module ContentView
      class Update < Actions::EntryAction
        def plan(content_view, content_view_params)
          repositories = repositories_to_reindex(content_view, content_view_params)

          action_subject content_view
          content_view.update_attributes!(content_view_params)

          if ::Katello.config.use_elasticsearch
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
