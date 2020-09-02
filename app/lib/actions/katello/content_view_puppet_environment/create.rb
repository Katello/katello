module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class Create < Actions::EntryAction
        def plan(puppet_environment, clone = false)
          internal_capsule = SmartProxy.pulp_primary
          fail _("Content View %s  cannot be published without an internal capsule." % puppet_environment.name) unless internal_capsule

          User.as_anonymous_admin { puppet_environment.save! }

          action_subject(puppet_environment)
          sequence do
            plan_self(:content_view_puppet_environment_id => puppet_environment.id)

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
              plan_action(Katello::Repository::MetadataGenerate, puppet_environment) if puppet_environment.environment
            end
          end
        end

        def run
          puppet_environment = ::Katello::ContentViewPuppetEnvironment.find(input[:content_view_puppet_environment_id])
          output[:response] = ::Katello::Pulp::Repository::Puppet.new(puppet_environment.nonpersisted_repository, SmartProxy.pulp_primary).create
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
