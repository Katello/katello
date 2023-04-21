module Actions
  module Katello
    module Organization
      module SimpleContentAccess
        class Toggle < Actions::AbstractAsyncTask
          middleware.use Actions::Middleware::PropagateCandlepinErrors
          include Helpers::Notifications

          SIMPLE_CONTENT_ACCESS_DISABLED_VALUE = "entitlement".freeze
          SIMPLE_CONTENT_ACCESS_ENABLED_VALUE = "org_environment".freeze

          attr_reader :organization

          def plan(organization_id)
            organization = ::Organization.find(organization_id.to_i)
            input[:organization_name] = organization.name
            input[:organization_label] = organization.label
            action_subject organization
            plan_self(organization_id: organization_id)
          end

          def run
            ::Katello::Resources::Candlepin::Owner.update(input[:organization_label], contentAccessMode: content_access_mode_value)
          end

          def failure_notification(plan)
            task_error_notification.deliver!(
              :subject => subject_organization,
              :task => get_foreman_task(plan)
            )
          end

          def success_notification(_plan)
            task_success_notification.deliver!(
              subject_organization
            )
          end

          def humanized_input
            _("for organization %s") % input[:organization_name]
          end

          private

          def consumer
            @consumer ||= @organization.owner_details['upstreamConsumer']
          end
        end
      end
    end
  end
end
