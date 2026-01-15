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

    def self.auto_publish!(content_view:, content_view_version:)
      request = content_view.create_auto_publish_request!(
        content_view_version: content_view_version
      )

      ForemanTasks.async_task(::Actions::Katello::ContentView::AutoPublish, request)
    end

    def self.auto_publish_composites!(content_view_version:)
      content_view_version.content_view.publishable_composites.each do |composite|
        begin
          auto_publish!(
            content_view_version: content_view_version,
            content_view: composite
          )
        rescue ActiveRecord::RecordNotUnique
          # Auto publish happened elsewhere - Don't block others from publishing
        end
      end
    end
  end
end
