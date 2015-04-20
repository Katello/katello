module Actions
  module Katello
    module ContentView
      class Create < Actions::Base
        def plan(content_view)
          content_view.save!
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
