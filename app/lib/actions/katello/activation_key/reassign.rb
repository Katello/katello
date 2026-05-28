module Actions
  module Katello
    module ActivationKey
      class Reassign < Actions::Base
        def plan(activation_key, content_view_id, environment_id)
          cvenv = ::Katello::ContentViewEnvironment.find_by_cv_and_lce!(content_view_id, environment_id)
          activation_key.content_view_environments = [cvenv]
          activation_key.save!
        end
      end
    end
  end
end
