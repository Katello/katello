module Actions
  module Katello
    module Host
      class Reassign < Actions::Base
        def plan(host, content_view_id, environment_id)
          host.content_facet.content_view = ::Katello::ContentView.find(content_view_id)
          host.content_facet.lifecycle_environment = ::Katello::KTEnvironment.find(environment_id)

          plan_action(::Actions::Katello::Host::Update, host)
        end
      end
    end
  end
end
