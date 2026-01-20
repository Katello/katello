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
      Rails.logger.info "auto publish request created id=#{request.id} content_view=#{content_view.id} content_view_version=#{content_view_version.id}"
      request
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.info "auto publish request exists content_view=#{content_view.id} content_view_version=#{content_view_version.id}"
      nil
    end

    def self.content_view_locks(content_view:)
      ForemanTasks::Lock.where(
        resource_id: content_view.id,
        resource_type: ::Katello::ContentView.to_s)
    end

    def self.trigger_auto_publish!(request:)
      destroy_request = true

      if content_view_locks(content_view: request.content_view).any?
        Rails.logger.info "auto publish locks found id=#{request.id} content_view=#{request.content_view_id} content_view_version=#{request.content_view_version_id}"
        destroy_request = false
        return
      end

      description = _("Auto Publish - Triggered by '%s'") % request.content_view_version.name
      ForemanTasks.async_task(Actions::Katello::ContentView::Publish, request.content_view, description, auto_published: true)
      Rails.logger.info "auto publish triggered id=#{request.id} content_view=#{request.content_view_id} content_view_version=#{request.content_view_version_id}"
    rescue ForemanTasks::Lock::LockConflict => e
      Rails.logger.info e
      Rails.logger.info "auto publish lock conflict id=#{request.id} content_view=#{request.content_view_id} content_view_version=#{request.content_view_version_id}"

      destroy_request = false
    ensure
      request.destroy! if destroy_request
    end
  end
end
