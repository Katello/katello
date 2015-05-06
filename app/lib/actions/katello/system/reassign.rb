module Actions
  module Katello
    module System
      class Reassign < Actions::Base
        def plan(system, content_view_id, environment_id)
          system.content_view_id = content_view_id
          system.environment_id = environment_id

          if system.foreman_host
            cve = ::Katello::ContentViewPuppetEnvironment.in_content_view(content_view_id).in_environment(environment_id).first
            if cve && cve.puppet_environment
              system.foreman_host.environment = cve.puppet_environment
              system.foreman_host.save!
            end

          end
          system.save!
          plan_action(::Actions::Candlepin::Consumer::Update, system)
        end
      end
    end
  end
end
