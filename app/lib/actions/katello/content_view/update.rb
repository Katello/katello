module Actions
  module Katello
    module ContentView
      class Update < Actions::EntryAction
        def plan(content_view, content_view_params)
          action_subject content_view
          content_view.update_attributes!(content_view_params)
        end
      end
    end
  end
end
