module Actions
  module Pulp3
    module CapsuleContent
      class GenerateMetadata < Pulp3::Abstract
        def plan(repository, smart_proxy, options = {})
          options[:contents_changed] = (options && options.key?(:contents_changed)) ? options[:contents_changed] : true
          sequence do
            plan_action(CreateVersion, repository, smart_proxy)
            plan_action(CreatePublication, repository, smart_proxy, options)
          end
        end
      end
    end
  end
end
