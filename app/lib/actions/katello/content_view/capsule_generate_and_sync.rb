module Actions
  module Katello
    module ContentView
      class CapsuleGenerateAndSync < Actions::Base
        def humanized_name
          _("Sync Smart proxy with Content View")
        end

        def plan(content_view, environment)
          sequence do
            concurrence do
              ::Katello::CapsuleContent.with_environment(environment).each do |capsule_content|
                plan_action(Katello::CapsuleContent::Sync, capsule_content, :content_view => content_view,
                            :environment => environment)
              end
            end
          end
        end
      end
    end
  end
end
