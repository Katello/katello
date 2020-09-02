module Actions
  module Pulp
    module Repository
      class RemoveUnits < Pulp::AbstractAsyncTask
        input_format do
          param :repo_id
          param :content_view_puppet_environment_id
          param :contents
          param :content_unit_type
        end

        def invoke_external_task
          fail _("Cannot pass content units without content unit type") if (input[:contents] && !input[:content_unit_type])
          if input[:repo_id]
            repo = ::Katello::Repository.find(input[:repo_id])
          else
            repo = ::Katello::ContentViewPuppetEnvironment.find(input[:content_view_puppet_environment_id]).nonpersisted_repository
          end
          fail _("An error occurred during content removal. Could not find repository with id: %s" % input[:repo_id]) unless repo
          tasks = []
          if input[:content_unit_type]
            content_type = ::Katello::RepositoryTypeManager.find_content_type(input[:content_unit_type].downcase)
            if input[:contents]
              units = content_type.model_class.where(:id => input[:contents])
              unit_pulp_ids = units.map(&:pulp_id).sort
            end
            tasks << ::SmartProxy.pulp_primary.content_service(content_type).remove(repo, unit_pulp_ids)
          else
            repo_content_types = ::Katello::RepositoryTypeManager.find(repo.content_type).content_types
            repo_content_types.each do |type|
              tasks << ::SmartProxy.pulp_primary.content_service(type).remove(repo)
            end
          end
          tasks
        end

        def external_task=(external_task_data)
          external_task_data = [external_task_data] if external_task_data.is_a?(Hash)
          super(external_task_data.map { |task| task.except('result') })
        end
      end
    end
  end
end
