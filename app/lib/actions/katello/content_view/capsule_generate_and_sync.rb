module Actions
  module Katello
    module ContentView
      class CapsuleGenerateAndSync < Actions::Base
        def humanized_name
          _("Generate Capsule Metadata and Sync")
        end

        def plan(content_view, environment)
          sequence do
            plan_action(NodeMetadataGenerate, content_view, environment)

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
