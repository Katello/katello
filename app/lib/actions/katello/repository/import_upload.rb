# rubocop:disable Lint/SuppressedException
module Actions
  module Katello
    module Repository
      class ImportUpload < Actions::EntryAction
        # rubocop:disable Metrics/MethodLength
        def plan(repository, uploads, options = {})
          action_subject(repository)
          repository.clear_smart_proxy_sync_histories
          repo_service = repository.backend_service(::SmartProxy.pulp_primary)

          upload_ids = uploads.pluck('id')
          unit_keys = repo_service.unit_keys(uploads)
          generate_metadata = options.fetch(:generate_metadata, true)
          sync_capsule = options.fetch(:sync_capsule, true)
          generate_applicability = options.fetch(:generate_applicability, repository.yum?)

          options[:content_type] ||= ::Katello::RepositoryTypeManager.find(repository.content_type).default_managed_content_type.label
          if ::Katello::RepositoryTypeManager.generic_content_type?(options[:content_type])
            unit_type_id = options[:content_type]
          else
            unit_type_id = SmartProxy.pulp_primary.content_service(options[:content_type])::CONTENT_TYPE
          end
          content_type = ::Katello::RepositoryTypeManager.find_content_type(options[:content_type])

          sequence do
            upload_results = concurrence do
              upload_ids.zip(unit_keys).collect do |upload_id, unit_key|
                unit_metadata = unit_key if unit_type_id == 'docker_tag'
                import_upload_args = {
                  pulp_id: repository.pulp_id,
                  unit_type_id: unit_type_id,
                  unit_key: unit_key.with_indifferent_access,
                  upload_id: upload_id,
                  unit_metadata: unit_metadata
                }

                import_upload_args.merge!(options)

                if content_type.repository_import_on_upload
                  action_class = ::Actions::Pulp3::Orchestration::Repository::ImportRepositoryUpload
                else
                  action_class = ::Actions::Pulp3::Orchestration::Repository::ImportUpload
                end

                import_upload = plan_action(action_class, repository, SmartProxy.pulp_primary, **import_upload_args)
                plan_action(FinishUpload, repository, :import_upload_task => import_upload.output,
                            generate_metadata: false, content_type: options[:content_type])
                import_upload.output
              end
            end
            plan_action(Katello::Repository::MetadataGenerate, repository, force_publication: true) if generate_metadata
            plan_action(Actions::Katello::Applicability::Repository::Regenerate, :repo_ids => [repository.id]) if generate_applicability
            plan_self(repository_id: repository.id, sync_capsule: sync_capsule, upload_results: upload_results)
          end
        end
        # rubocop:enable Metrics/MethodLength

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          if input[:sync_capsule]
            ForemanTasks.async_task(Katello::Repository::CapsuleSync, repository) if Setting[:foreman_proxy_content_auto_sync]
          end
          output[:upload_results] = results_to_json(input[:upload_results])
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Upload into")
        end

        def results_to_json(results)
          json_results = []
          results.each do |result|
            result[:pulp_tasks]&.each do |task|
              details = task ? task.dig(:result, :details, :unit) : nil
              if details && details.dig('type_id') == 'docker_manifest'
                manifest = ::Katello::DockerManifest.find_by(:pulp_id => details.dig(:metadata, :id))
                json_result = JSON.parse(::Rabl.render(manifest, '/katello/api/v2/docker_manifests/show'))
                json_result[:type] = 'docker_manifest'
                json_results << json_result
              elsif details && details.dig('type_id') == 'docker_tag'
                manifest = ::Katello::DockerTag.find_by(:pulp_id => details.dig(:metadata, :id))
                json_result = JSON.parse(::Rabl.render(manifest, '/katello/api/v2/docker_tags/show'))
                json_result[:type] = 'docker_tag'
                json_results << json_result
              else
                json_results << {:type => 'file'}
              end
            end
            unless json_results.size
              if result[:content_unit_href]
                json_results << {:type => 'file'}
              end
            end
          end
          json_results
        end
      end
    end
  end
end
