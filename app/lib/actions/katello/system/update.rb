module Actions
  module Katello
    module System
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, sys_params)
          action_subject system
          sys_params.delete(:type)
          system.update_attributes!(sys_params)

          reset_puppet_env = system.foreman_host.content_and_puppet_match?

          if system.foreman_host.content_facet
            system.foreman_host.content_facet.content_view = system.content_view
            system.foreman_host.content_facet.lifecycle_environment = system.environment
          end

          if system.foreman_host.subscription_facet
            system.foreman_host.subscription_facet.service_level = system.serviceLevel
            system.foreman_host.subscription_facet.autoheal = system.autoheal
          end

          plan_action(::Actions::Katello::Host::Update, system.foreman_host)

          host = system.foreman_host
          if host && host.content_facet.try(:lifecycle_environment) && host.content_facet.try(:content_view) && reset_puppet_env
            new_env = system.content_view.puppet_env(system.environment).try(:puppet_environment)
            if new_env
              host.environment = new_env
            else
              fail ::Katello::Errors::NotFound,
                   _("Couldn't find puppet environment associated with lifecycle environment '%{env}' and content view '%{view}'") %
                       { :env =>  host.content_facet.lifecycle_environment.name, :view => host.content_facet.content_view.name }
            end
            host.save!
          end
        end
      end
    end
  end
end
