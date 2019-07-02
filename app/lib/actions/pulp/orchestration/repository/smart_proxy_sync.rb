module Actions
  module Pulp
    module Orchestration
      module Repository
        class SmartProxySync < Pulp::Abstract
          include Actions::Katello::PulpSelector

          # rubocop:disable MethodLength
          def plan(repository, smart_proxy, options)
            content_view = options[:content_view]
            environment = options[:environment]
            skip_metadata_check = options.fetch(:skip_metadata_check, false)
            sequence do
              refresh_options = {}
              refresh_options[:content_view_id] = content_view.id if content_view
              refresh_options[:environment_id] = environment.id if environment
              refresh_options[:repository_id] = repository.id if repository

              if repository && ['yum', 'puppet'].exclude?(repository.content_type)
                # we unassociate units in non-yum/puppet repos in order to avoid version conflicts
                # during publish. (i.e. two versions of a unit in the same repository)
                plan_pulp_action([Pulp::Consumer::UnassociateUnits], repository, smart_proxy_service.smart_proxy, {})
              end
              pulp_options = { remove_missing: repository && ["deb", "puppet", "yum"].include?(repository.content_type) }
              pulp_options[:force_full] = true if skip_metadata_check && repository.content_type == "yum"

              plan_action(Pulp::Consumer::SyncCapsule,
                               repository, smart_proxy, pulp_options)
              if skip_metadata_check
                plan_action(Katello::Repository::MetadataGenerate,
                            repository,
                            capsule_id: smart_proxy.id,
                            force: true)
              end
            end
          end
        end
      end
    end
  end
end
