module Actions
  module Katello
    module ContentView
      class Create < Actions::Base
        def plan(content_view)
          content_view.disable_auto_reindex! if ::Katello.config.use_elasticsearch
          content_view.save!
          plan_action(ElasticSearch::Reindex, content_view) if ::Katello.config.use_elasticsearch
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
