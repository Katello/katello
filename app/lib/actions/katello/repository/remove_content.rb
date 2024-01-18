module Actions
  module Katello
    module Repository
      class RemoveContent < Actions::EntryAction
        include Dynflow::Action::WithSubPlans

        def plan(repository, content_units, options = {})
          sync_capsule = options.fetch(:sync_capsule, true)
          if repository.redhat?
            fail _("Cannot remove content from a non-custom repository")
          end
          unless repository.content_view.default?
            fail _("Can only remove content from within the Default Content View")
          end
          content_units = valid_docker_manifests_to_delete!(content_units) if (repository.docker? && content_units.first.class::CONTENT_TYPE == 'docker_manifest')
          action_subject(repository)

          content_unit_ids = content_units.map(&:id)
          if repository.generic?
            content_unit_type = options[:content_type] || content_units.first.content_type
          else
            content_unit_type = options[:content_type] || content_units.first.class::CONTENT_TYPE
          end
          ::Katello::RepositoryTypeManager.check_content_matches_repo_type!(repository, content_unit_type)

          generate_applicability = options.fetch(:generate_applicability, repository.yum?)

          sequence do
            remove_content_args = {
              :contents => content_unit_ids,
              :content_unit_type => content_unit_type}
            repository.clear_smart_proxy_sync_histories
            pulp_action = plan_action(
              Pulp3::Orchestration::Repository::RemoveUnits,
              repository, SmartProxy.pulp_primary, **remove_content_args)
            return if pulp_action.error
            plan_self(:content_unit_class => content_units.first.class.name, :content_unit_ids => content_unit_ids)
            plan_action(CapsuleSync, repository) if sync_capsule
            plan_action(Actions::Katello::Applicability::Repository::Regenerate, :repo_ids => [repository.id]) if generate_applicability
          end
        end

        def create_sub_plans
          trigger(Actions::Katello::Repository::MetadataGenerate,
                  ::Katello::Repository.find(input[:repository][:id]), :force_publication => true)
        end

        def resource_locks
          :link
        end

        def finalize
          if (input[:content_unit_class] && input[:content_unit_ids])
            content_units = input[:content_unit_class].constantize.where(:id => input[:content_unit_ids])
            content_units.each do |content_unit|
              content_unit.remove_from_repository(input[:repository][:id])
            end
          end
        end

        def valid_docker_manifests_to_delete!(content_units)
          original_content_units = content_units
          content_units = content_units.reject { |dm| dm.docker_tags.count > 0 || dm.docker_manifest_lists.count > 0 }
          Rails.logger.warn("Docker Manifests with tags or manifest lists will be ignored; continuing...") if original_content_units.count != content_units.count
          fail _("No docker manifests to delete after ignoring manifests with tags or manifest lists") if content_units.count == 0
          content_units
        end

        def humanized_name
          _("Remove Content")
        end
      end
    end
  end
end
