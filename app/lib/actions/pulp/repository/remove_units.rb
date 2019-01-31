module Actions
  module Pulp
    module Repository
      class RemoveUnits < Pulp::AbstractAsyncTask
        input_format do
          param :repo_id
          param :contents
          param :content_unit_type
        end

        def invoke_external_task
          repo = ::Katello::Repository.find_by(:id => input[:repo_id])
          if repo.nil?
            repo = ::Katello::ContentViewPuppetEnvironment.find_by(:id => input[:repo_id])
            repo = repo.nonpersisted_repository
          end
          repo_content_types = ::Katello::RepositoryTypeManager.find(repo.content_type).content_types
          tasks = []
          if input[:contents]
            if input[:content_unit_type]
              content_type = ::Katello::RepositoryTypeManager.find_content_type(input[:content_unit_type].downcase)
              units = content_type.model_class.where(:id => input[:contents])
              unit_pulp_ids = units.map(&:pulp_id)
              tasks << ::SmartProxy.pulp_master.content_service(content_type).remove(repo, unit_pulp_ids)
            else
              user_removable_content_types = ::Katello::RepositoryTypeManager.find(repo.content_type).user_removable_content_types
              user_removable_content_types.each do |user_removable_content_type|
                units = user_removable_content_type.model_class.where(:id => input[:contents])
                unit_pulp_ids = units.map(&:pulp_id)
                tasks << ::SmartProxy.pulp_master.content_service(user_removable_content_type).remove(repo, unit_pulp_ids) unless unit_pulp_ids.blank?
              end
            end
          elsif input[:content_unit_type]
            content_type = ::Katello::RepositoryTypeManager.find_content_type(input[:content_unit_type].downcase)
            tasks << ::SmartProxy.pulp_master.content_service(content_type).remove(repo)
          else
            repo_content_types.each do |type|
              tasks << ::SmartProxy.pulp_master.content_service(type).remove(repo)
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
