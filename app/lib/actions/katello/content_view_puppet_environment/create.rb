module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class Create < Actions::EntryAction
        def plan(puppet_environment, clone = false)
          internal_capsule = SmartProxy.default_capsule
          puppet_path = internal_capsule.present? ? puppet_environment.generate_puppet_path(internal_capsule) : nil

          User.as_anonymous_admin { puppet_environment.save! }

          action_subject(puppet_environment)
          plan_self

          sequence do
            plan_action(Pulp::Repository::Create,
                        content_type: ::Katello::Repository::PUPPET_TYPE,
                        pulp_id: puppet_environment.pulp_id,
                        name: puppet_environment.name,
                        with_importer: true,
                        path: puppet_path)

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            if !clone && puppet_path
              plan_action(Katello::Repository::MetadataGenerate, puppet_environment) if puppet_environment.environment
            end
          end
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
