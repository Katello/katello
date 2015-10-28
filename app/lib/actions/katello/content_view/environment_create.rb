module Actions
  module Katello
    module ContentView
      class EnvironmentCreate < Actions::Base
        def plan(content_view_environment)
          content_view_environment.save!
          if ::SETTINGS[:katello][:use_cp]
            content_view = content_view_environment.content_view
            plan_action(Candlepin::Environment::Create,
                        organization_label: content_view.organization.label,
                        cp_id:              content_view_environment.cp_id,
                        name:               content_view_environment.label,
                        description:        content_view.description)
          end
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
