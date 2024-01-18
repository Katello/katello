module Actions
  module Katello
    module CapsuleContent
      class Sync < ::Actions::EntryAction
        include ::Actions::ObservableAction
        def resource_locks
          :link
        end

        execution_plan_hooks.use :notify_on_failure, :on => [:failure, :paused]

        input_format do
          param :name
        end

        def humanized_name
          _("Synchronize smart proxy")
        end

        def humanized_input
          input['smart_proxy'].nil? || input['smart_proxy']['name'].nil? ? super : ["'#{input['smart_proxy']['name']}'"] + super
        end

        def plan(smart_proxy, options = {})
          input[:options] = options

          action_subject(smart_proxy)
          smart_proxy.verify_ueber_certs

          subjects = subjects(options)

          fail _("Action not allowed for the default smart proxy.") if smart_proxy.pulp_primary?

          refresh_options = options.merge(subjects)
          sequence do
            if smart_proxy.has_feature?(SmartProxy::PULP3_FEATURE)
              plan_action(Actions::Pulp3::ContentGuard::Refresh, smart_proxy)
            end
            plan_action(SyncCapsule, smart_proxy, **refresh_options)
          end
          plan_self(smart_proxy_id: smart_proxy.id)
        end

        def finalize
          smart_proxy = SmartProxy.unscoped.authorized(:view_capsule_content).find(input[:smart_proxy_id])
          unless smart_proxy&.pulp_primary?
            smart_proxy&.audit_capsule_sync
          end
        end

        def notify_on_failure(_plan)
          notification = MailNotification[:proxy_sync_failure]
          proxy = SmartProxy.find(input.fetch(:smart_proxy, {})[:id])
          subjects = subjects(input[:options]).merge(smart_proxy: proxy)
          notification.users.where(disabled: [nil, false], mail_enabled: true).each do |user|
            notification.deliver(subjects.merge(user: user, task: task))
          end
        end

        def subjects(options = {})
          environment_id = options.fetch(:environment_id, nil)
          environment = ::Katello::KTEnvironment.find(environment_id) if environment_id

          repository_id = options.fetch(:repository_id, nil)
          repository = ::Katello::Repository.find(repository_id) if repository_id

          content_view_id = options.fetch(:content_view_id, nil)
          content_view = ::Katello::ContentView.find(content_view_id) if content_view_id

          {content_view: content_view, environment: environment, repository: repository}
        end
      end
    end
  end
end
