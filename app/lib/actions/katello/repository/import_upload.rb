# rubocop:disable HandleExceptions
module Actions
  module Katello
    module Repository
      class ImportUpload < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        def plan(repository, upload_ids, options = {})
          action_subject(repository)

          unit_keys = options.fetch(:unit_keys, {})
          generate_metadata = options.fetch(:generate_metadata, true)
          sync_capsule = options.fetch(:sync_capsule, true)
          unit_type_id = options.fetch(:unit_type_id, repository.unit_type_id)

          sequence do
            upload_results = concurrence do
              upload_ids.zip(unit_keys).collect do |upload_id, unit_key|
                if unit_type_id == 'docker_tag'
                  unit_metadata = unit_key
                end
                import_upload = plan_action(Pulp::Repository::ImportUpload,
                                            pulp_id: repository.pulp_id,
                                            unit_type_id: unit_type_id,
                                            unit_key: unit_key,
                                            upload_id: upload_id,
                                            unit_metadata: unit_metadata)

                plan_action(FinishUpload, repository, :dependency => import_upload.output,
                            generate_metadata: false)
                import_upload.output
              end
            end
            plan_action(Katello::Repository::MetadataGenerate, repository) if generate_metadata
            plan_self(repository_id: repository.id, sync_capsule: sync_capsule, upload_results: upload_results)
          end
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          if input[:sync_capsule]
            ForemanTasks.async_task(Katello::Repository::CapsuleSync, repository)
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
            result[:pulp_tasks].each do |task|
              details = task ? task.dig(:result, :details, :unit) : nil
              if details && details.dig('type_id') == 'docker_manifest'
                manifest = ::Katello::DockerManifest.find_by_uuid(details.dig(:metadata, :id))
                json_result = JSON.parse(::Rabl.render(manifest, '/katello/api/v2/docker_manifests/show'))
                json_result[:type] = 'docker_manifest'
                json_results << json_result
              elsif details && details.dig('type_id') == 'docker_tag'
                manifest = ::Katello::DockerTag.find_by_uuid(details.dig(:metadata, :id))
                json_result = JSON.parse(::Rabl.render(manifest, '/katello/api/v2/docker_tags/show'))
                json_result[:type] = 'docker_tag'
                json_results << json_result
              else
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
