module Actions
  module Katello
    module Repository
      class RemoveContent < Actions::EntryAction
        def plan(repository, uuids)
          if repository.redhat?
            fail _("Cannot remove content from a non-custom repository")
          end
          unless repository.content_view.default?
            fail _("Can only remove content from within the Default Content View")
          end

          action_subject(repository)

          pulp_action, index_action = case repository.content_type
                                      when ::Katello::Repository::YUM_TYPE
                                        [Pulp::Repository::RemoveRpm, ElasticSearch::Repository::RemovePackages]
                                      when ::Katello::Repository::PUPPET_TYPE
                                        [Pulp::Repository::RemovePuppetModule, ElasticSearch::Repository::RemovePuppetModules]
                                      when ::Katello::Repository::DOCKER_TYPE
                                        [Pulp::Repository::RemoveDockerImage, Katello::Repository::RemoveDockerImages]
                                      end

          sequence do
            plan_action(pulp_action, :pulp_id => repository.pulp_id,
                                     :clauses => {:association => {'unit_id' => {'$in' => uuids}}
            })
            plan_action(index_action, :pulp_id => repository.pulp_id, :uuids => uuids)

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
          ::User.current = ::User.find(input['user_id'])
          output[:task_id] = ForemanTasks.async_task(Actions::Katello::Repository::MetadataGenerate,
                                                     ::Katello::Repository.find(input['repository_id'])).id
        ensure
          ::User.current = nil
        end
      end
    end
  end
end
