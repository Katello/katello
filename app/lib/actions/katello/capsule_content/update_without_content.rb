module Actions
  module Katello
    module CapsuleContent
      class UpdateWithoutContent < ::Actions::EntryAction
        def plan(environment)
          ::Katello::CapsuleContent.with_environment(environment).each do |capsule_content|
            plan_action(Pulp::Consumer::SyncNode,
                        consumer_uuid: capsule_content.consumer_uuid,
                        skip_content: true)
          end
        end
      end
    end
  end
end
