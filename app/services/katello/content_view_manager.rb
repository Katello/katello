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
      if scheduled_composite_publish?(content_view)
        auto_publish_log(nil, "composite publish already scheduled for ID #{content_view.id}, skipping")
        return
      end

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
        composite_cv = request.content_view

        if content_view_locks(content_view: composite_cv).any?
          auto_publish_log(request, "locks found")
          return
        end

        description = _("Auto Publish - Triggered by '%s'") % request.content_view_version.name

        # Find running component CV publish tasks for chaining
        sibling_task_ids = running_component_publish_task_ids(composite_cv)

        if sibling_task_ids.any?
          # Chain composite publish to wait for running component CVs
          ForemanTasks.dynflow.world.chain(
            sibling_task_ids,
            Actions::Katello::ContentView::Publish,
            composite_cv,
            description,
            auto_published: true,
            triggered_by_id: request.content_view_version_id
          )
          auto_publish_log(request, "task chained to #{sibling_task_ids.size} component tasks")
        else
          # No component CVs running, publish immediately
          ForemanTasks.async_task(Actions::Katello::ContentView::Publish, composite_cv, description, auto_published: true, triggered_by_id: request.content_view_version_id)
          auto_publish_log(request, "task triggered")
        end
        request.destroy!
      rescue ForemanTasks::Lock::LockConflict => e
        auto_publish_log(request, e)
        auto_publish_log(request, "lock conflict")
      end
    rescue ActiveRecord::RecordNotFound
      auto_publish_log(request, "request gone")
    end

    def self.scheduled_composite_publish?(composite_cv)
      ForemanTasks::Task::DynflowTask
        .for_action(::Actions::Katello::ContentView::Publish)
        .where(state: 'scheduled')
        .any? do |task|
          delayed_plan = ForemanTasks.dynflow.world.persistence.load_delayed_plan(task.external_id)
          args = delayed_plan.args
          args.first.is_a?(::Katello::ContentView) && args.first.id == composite_cv.id
        end
    end

    def self.running_component_publish_task_ids(composite_cv)
      component_cv_ids = composite_cv.components.pluck(:content_view_id)
      return [] if component_cv_ids.empty?

      tasks = ForemanTasks::Task::DynflowTask
        .for_action(::Actions::Katello::ContentView::Publish)
        .where(state: ['planning', 'planned', 'running'])
        .select do |task|
          task_input = task.input
          task_input && component_cv_ids.include?(task_input.dig('content_view', 'id'))
        end
      tasks.map(&:external_id)
    end
  end
end
