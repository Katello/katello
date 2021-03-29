module Actions
  module Katello
    module JailConcern
      module ContentView
        def content_view_id
          input['content_view']['id']
        end

        def content_view_name
          input['content_view']['name']
        end

        def content_view_label
          input['content_view']['label']
        end

        def self.included(base)
          super
          base.instance_eval do
            apipie :class do
              property :content_view_id, Integer, desc: 'Returns the id of the content view'
              property :content_view_name, String, desc: 'Returns the name of the content view'
              property :content_view_label, String, desc: 'Returns the label of the content view'
            end
          end
        end
      end
    end
  end
end
