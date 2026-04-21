module Actions
  module Katello
    module ContentViewEnvironment
      class ReassignObjects < Actions::Base
        def plan(content_view_environment, options)
          concurrence do
            content_view_environment.hosts.each do |host|
              content_facet_attributes = host.content_facet
              if content_facet_attributes.multi_content_view_environment?
                content_facet_attributes.content_view_environments -= [content_view_environment]
              else
                plan_action(Host::Reassign, host, options[:system_content_view_id], options[:system_environment_id])
              end
            end

            content_view_environment.activation_keys.each do |key|
              if key.multi_content_view_environment?
                key.content_view_environments = key.content_view_environments - [content_view_environment]
              else
                plan_action(ActivationKey::Reassign, key, options[:key_content_view_id], options[:key_environment_id])
              end
            end

            content_view_environment.hostgroups.each do |hostgroup|
              reassign_hostgroup(hostgroup, options[:hostgroup_content_view_environment_id])
            end
          end
        end

        private

        def reassign_hostgroup(hostgroup, cv_env_id)
          return unless cv_env_id

          cv_env = ::Katello::ContentViewEnvironment.find_by(id: cv_env_id)
          hostgroup.content_view_environment = cv_env if cv_env
          hostgroup.save!
        end
      end
    end
  end
end
