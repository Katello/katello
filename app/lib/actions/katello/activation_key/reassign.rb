module Actions
  module Katello
    module ActivationKey
      class Reassign < Actions::Base
        def plan(activation_key, content_view_id, environment_id)
          activation_key.assign_single_environment(
            content_view: ::Katello::ContentView.find(content_view_id),
            lifecycle_environment: ::Katello::KTEnvironment.find(environment_id)
          )
        end
      end
    end
  end
end
