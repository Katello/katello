module Actions
  module Katello
    module Repository
      class RemoveContent < Actions::EntryAction
        include Dynflow::Action::WithSubPlans

        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(repository, content_units, options = {})
          sync_capsule = options.fetch(:sync_capsule, true)
          if repository.redhat?
            fail _("Cannot remove content from a non-custom repository")
          end
          unless repository.content_view.default?
            fail _("Can only remove content from within the Default Content View")
          end

          action_subject(repository)

          pulp_action = case repository.content_type
                        when ::Katello::Repository::YUM_TYPE
                          Pulp::Repository::RemoveRpm
                        when ::Katello::Repository::PUPPET_TYPE
                          Pulp::Repository::RemovePuppetModule
                        when ::Katello::Repository::DOCKER_TYPE
                          Pulp::Repository::RemoveDockerManifest
                        when ::Katello::Repository::FILE_TYPE
                          Pulp::Repository::RemoveFile
                        when ::Katello::Repository::DEB_TYPE
                          Pulp::Repository::RemoveDeb
                        end

          uuids = content_units.map(&:uuid)
          repository.remove_content(content_units)

          sequence do
            plan_action(pulp_action, :pulp_id => repository.pulp_id,
                                     :clauses => {:association => {'unit_id' => {'$in' => uuids}}
            })
            plan_self
            plan_action(CapsuleGenerateAndSync, repository) if sync_capsule
          end
        end

        def create_sub_plans
          trigger(Actions::Katello::Repository::MetadataGenerate,
                  ::Katello::Repository.find(input[:repository][:id]))
        end

        def resource_locks
          :link
        end

        def humanized_name
          _("Remove Content")
        end
      end
    end
  end
end
