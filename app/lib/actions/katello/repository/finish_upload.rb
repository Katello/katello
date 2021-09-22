module Actions
  module Katello
    module Repository
      class FinishUpload < Actions::Base
        def plan(repository, options = {})
          import_upload_task = options.fetch(:import_upload_task, nil)
          upload_actions = options.fetch(:upload_actions, nil)
          content_type = options.fetch(:content_type)
          if content_type
            unit_type_id = SmartProxy.pulp_primary.content_service(content_type)::CONTENT_TYPE
          else
            content_type = repository.content_type
            unit_type_id = SmartProxy.pulp_primary.content_service(content_type)::CONTENT_TYPE
          end
          generate_metadata = options.fetch(:generate_metadata, true)
          plan_action(Katello::Repository::MetadataGenerate, repository, :dependency => import_upload_task, :force_publication => true) if generate_metadata

          recent_range = 5.minutes.ago.utc.iso8601
          plan_action(Katello::Repository::FilteredIndexContent,
                      id: repository.id,
                      filter: {:association => {:created => {"$gt" => recent_range}}},
                      content_type: unit_type_id,
                      import_upload_task: import_upload_task,
                      upload_actions: upload_actions)
        end
      end
    end
  end
end
