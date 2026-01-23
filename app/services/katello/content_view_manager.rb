module Katello
  class ContentViewManager
    def self.add_version_to_environment(content_view_version:, environment:)
      content_view = content_view_version.content_view
      if (cve = content_view.content_view_environment(environment))
        content_view_version.content_view_environments << cve
      else
        cve = content_view.add_environment(environment, content_view_version)
      end
      cve
    end

    def self.create_candlepin_environment(content_view_environment:)
      unless content_view_environment.exists_in_candlepin?
        ::Katello::Resources::Candlepin::Environment.create(
          content_view_environment.content_view.organization.label,
          content_view_environment.cp_id,
          content_view_environment.label,
          content_view_environment.content_view.description.try(:truncate, 255)
        )
      end
    end

    def self.request_auto_publish(content_view:, content_view_version:)
      request = content_view.create_auto_publish_request!(
        content_view_version: content_view_version
      )
      auto_publish_log(request, "request created")

      request
    rescue ActiveRecord::RecordNotUnique
      auto_publish_log(content_view.auto_publish_request, "request exists")
      content_view.auto_publish_request
    end

    def self.auto_publish_log(request, message)
      logged_request = Katello::Logging.join_parts(request.try(:slice, :id, :content_view_id, :content_view_version_id, :created_at))
      Rails.logger.info "[auto publish] #{message} #{logged_request}"
    end

    def self.content_view_locks(content_view:)
      ForemanTasks::Lock.where(
        resource_id: content_view.id,
        resource_type: ::Katello::ContentView.to_s)
    end

    def self.trigger_auto_publish!(request:)
      request.with_lock do
        destroy_request = true

        if content_view_locks(content_view: request.content_view).any?
          auto_publish_log(request, "locks found")
          destroy_request = false
          return
        end

        description = _("Auto Publish - Triggered by '%s'") % request.content_view_version.name
        ForemanTasks.async_task(Actions::Katello::ContentView::Publish, request.content_view, description, auto_published: true, triggered_by_id: request.content_view_version_id)
        auto_publish_log(request, "task triggered")
      rescue ForemanTasks::Lock::LockConflict => e
        auto_publish_log(request, e)
        auto_publish_log(request, "lock conflict")

        destroy_request = false
      ensure
        request.destroy! if destroy_request
      end
    rescue ActiveRecord::RecordNotFound
      auto_publish_log(request, "request deleted; skipping trigger")
    end
  end
end
