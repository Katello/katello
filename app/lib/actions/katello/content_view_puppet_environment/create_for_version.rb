module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class CreateForVersion < Actions::Base
        # allows accessing the build object from the superior action
        attr_accessor :new_puppet_environment

        def plan(content_view_version)
          content_view = content_view_version.content_view
          modules_by_repoid = content_view.computed_module_ids_by_repoid

          self.new_puppet_environment = content_view.build_puppet_env(:version => content_view_version)

          sequence do
            plan_action(ContentViewPuppetEnvironment::Create, new_puppet_environment, true)
            plan_action(ContentViewPuppetEnvironment::CloneContent, new_puppet_environment, modules_by_repoid)
          end
        end
      end
    end
  end
end
