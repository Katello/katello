module Actions
  module Katello
    module Repository
      class RemoveContent < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(repository, content_units)
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
                        end

          uuids = content_units.map(&:uuid)
          repository.remove_content(content_units)

          sequence do
            plan_action(pulp_action, :pulp_id => repository.pulp_id,
                                     :clauses => {:association => {'unit_id' => {'$in' => uuids}}
            })

            plan_self(:repository_id => repository.id, :user_id => ::User.current.id)
          end
        end

        def resource_locks
          :link
        end

        def humanized_name
          _("Remove Content")
        end

        def run
          output[:task_id] = ForemanTasks.async_task(Actions::Katello::Repository::MetadataGenerate,
                                                     ::Katello::Repository.find(input['repository_id'])).id
        end
      end
    end
  end
end
