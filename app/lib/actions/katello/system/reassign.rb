module Actions
  module Katello
    module System
      class Reassign < Actions::Base
        def plan(system, content_view_id, environment_id)
          system.foreman_host.content_aspect.content_view = ::Katello::ContentView.find(content_view_id)
          system.foreman_host.content_aspect.lifecycle_environment = ::Katello::KTEnvironment.find(environment_id)

          plan_action(::Actions::Katello::Host::Update, system.foreman_host)
        end
      end
    end
  end
end
