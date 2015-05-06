module Actions
  module Katello
    module ActivationKey
      class Reassign < Actions::Base
        def plan(activation_key, content_view_id, environment_id)
          activation_key.content_view_id = content_view_id
          activation_key.environment_id = environment_id
          activation_key.save!
        end
      end
    end
  end
end
