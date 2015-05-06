module Actions
  module Katello
    module ContentViewEnvironment
      class ReassignObjects < Actions::Base
        def plan(content_view_environment, options)
          concurrence do
            content_view_environment.systems.each do |system|
              plan_action(System::Reassign, system, options[:system_content_view_id], options[:system_environment_id])
            end

            content_view_environment.activation_keys.each do |key|
              plan_action(ActivationKey::Reassign, key, options[:key_content_view_id], options[:key_environment_id])
            end
          end
        end
      end
    end
  end
end
