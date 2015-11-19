module Actions
  module Katello
    module System
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, sys_params)
          action_subject system
          system.update_attributes!(sys_params)

          reset_puppet_env = system.foreman_host.content_and_puppet_match?

          if system.foreman_host.content_aspect
            system.foreman_host.content_aspect.content_view = system.content_view
            system.foreman_host.content_aspect.lifecycle_environment = system.environment
          end

          if system.foreman_host.subscription_aspect
            system.foreman_host.subscription_aspect.service_level = system.serviceLevel
            system.foreman_host.subscription_aspect.autoheal = system.autoheal
          end

          plan_action(::Actions::Katello::Host::Update, system.foreman_host)

          host = system.foreman_host
          if host && host.content_aspect.try(:lifecycle_environment) && host.content_aspect.try(:content_view) && reset_puppet_env
            new_env = system.content_view.puppet_env(system.environment).try(:puppet_environment)
            if new_env
              host.environment = new_env
            else
              fail ::Katello::Errors::NotFound,
                   _("Couldn't find puppet environment associated with lifecycle environment '%{env}' and content view '%{view}'") %
                       { :env =>  host.content_aspect.lifecycle_environment.name, :view => host.content_aspect.content_view.name }
            end
            host.save!
          end
        end
      end
    end
  end
end
