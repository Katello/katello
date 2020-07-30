module Actions
  module Pulp
    module Orchestration
      module Repository
        class SmartProxySync < Pulp::Abstract
          def plan(repository, smart_proxy, options)
            skip_metadata_check = options.fetch(:skip_metadata_check, false)
            sequence do
              if repository && ['yum', 'puppet'].exclude?(repository.content_type)
                # we unassociate units in non-yum/puppet repos in order to avoid version conflicts
                # during publish. (i.e. two versions of a unit in the same repository)
                plan_action(Pulp::Consumer::UnassociateUnits,
                             capsule_id: smart_proxy.id,
                             repo_pulp_id: repository.pulp_id)
              end
              pulp_options = { remove_missing: repository && ["deb", "puppet", "yum"].include?(repository.content_type) }
              pulp_options[:force_full] = true if skip_metadata_check && repository.content_type == "yum"
              pulp_options[:repair_sync] = true if skip_metadata_check && repository.content_type == "deb"

              plan_action(Pulp::Consumer::SyncCapsule,
                               repository, smart_proxy, pulp_options)
              if skip_metadata_check
                plan_action(Katello::Repository::MetadataGenerate,
                            repository,
                            smart_proxy: smart_proxy,
                            force: true)
              end
            end
          end
        end
      end
    end
  end
end
