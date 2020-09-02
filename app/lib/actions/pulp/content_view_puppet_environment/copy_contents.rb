module Actions
  module Pulp
    module ContentViewPuppetEnvironment
      class CopyContents < Pulp::AbstractAsyncTask
        def plan(target_env, options = {})
          unless options[:source_repository_id] || options[:source_content_view_puppet_environment_id]
            fail 'Must provide source_repository_id or source_content_view_puppet_environment_id'
          end

          to_plan = {
            target_content_view_puppet_environment_id: target_env.id,
            source_content_view_puppet_environment_id: options[:source_content_view_puppet_environment_id],
            source_repository_id: options[:source_repository_id]
          }

          to_plan[:puppet_module_ids] = options[:puppet_modules].pluck(:id) if options[:puppet_modules]
          plan_self(to_plan)
        end

        def invoke_external_task
          if input[:source_repository_id]
            source_repository = ::Katello::Repository.find(input[:source_repository_id])
          else
            env = ::Katello::ContentViewPuppetEnvironment.find(input[:source_content_view_puppet_environment_id])
            source_repository = env.nonpersisted_repository
          end

          target_env = ::Katello::ContentViewPuppetEnvironment.find(input[:target_content_view_puppet_environment_id])

          puppet_modules = input[:puppet_module_ids] ? ::Katello::PuppetModule.where(:id => input[:puppet_module_ids]) : nil
          source_repository.backend_service(SmartProxy.pulp_primary).copy_contents(target_env.nonpersisted_repository, puppet_modules: puppet_modules)
        end
      end
    end
  end
end
