module Actions
  module Katello
    module Host
      class Reassign < Actions::Base
        def plan(host, content_view_id, environment_id)
          host.content_facet.assign_single_environment(
            content_view: ::Katello::ContentView.find(content_view_id),
            lifecycle_environment: ::Katello::KTEnvironment.find(environment_id)
          )
          host.update_candlepin_associations
        end
      end
    end
  end
end
