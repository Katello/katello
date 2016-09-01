module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class Create < Actions::EntryAction
        def plan(puppet_environment, clone = false)
          internal_capsule = SmartProxy.default_capsule
          fail _("Content View %s  cannot be published without an internal capsule." % puppet_environment.name) unless internal_capsule
          puppet_environment.save!
          action_subject(puppet_environment)
          plan_self

          puppet_path = puppet_environment.generate_puppet_path(internal_capsule)

          sequence do
            plan_action(Pulp::Repository::Create,
                        content_type: ::Katello::Repository::PUPPET_TYPE,
                        pulp_id: puppet_environment.pulp_id,
                        name: puppet_environment.name,
                        with_importer: true,
                        path: puppet_path)

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
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
