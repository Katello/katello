module Actions
  module Katello
    module ContentView
      class AutoPublish < Actions::EntryAction
        include Dynflow::Action::Polling

        def plan(auto_publish_request)
          action_subject(auto_publish_request)

          plan_self(auto_publish_request_id: auto_publish_request.id)
        end

        def content_view_locks(content_view_id)
          ForemanTasks::Lock.where(
            resource_id: content_view_id,
            resource_type: ::Katello::ContentView.to_s)
        end

        def done?
          external_task.present? # Was the async task started?
        end

        def poll_external_task
          initiate_external_action
        end

        def invoke_external_task
          request = ::Katello::ContentViewAutoPublishRequest.find(input[:auto_publish_request_id])

          # Checking for locks avoids creating tasks failing with lock errors
          if content_view_locks(request.content_view_id).any?
            Rails.logger.info "Locks found, sleeping"
          else
            description = _("Auto Publish - Triggered by '%s'") % request.content_view_version.name
            begin
              return ForemanTasks.async_task(Publish, request.content_view, description, triggered_by_id: request.content_view_version_id).as_json
            rescue ForemanTasks::Lock::LockConflict
              Rails.logger.info "Got a lock conflict, sleeping"
            end
          end

          nil
        end

        def finalize
          request = ::Katello::ContentViewAutoPublishRequest.find(input[:auto_publish_request_id])
          request.destroy!
        end
      end
    end
  end
end
