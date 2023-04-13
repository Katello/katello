module Actions
  module Katello
    module Organization
      module SimpleContentAccess
        class Enable < Toggle
          def plan(organization_id, auto_create_overrides: true)
            input[:auto_create_overrides] = auto_create_overrides
            sequence do
              if auto_create_overrides
                plan_action(PrepareContentOverrides, organization_id)
              end
              super(organization_id) # puts plan_self inside the sequence
            end
          end

          def content_access_mode_value
            SIMPLE_CONTENT_ACCESS_ENABLED_VALUE
          end

          def humanized_name
            N_("Enable Simple Content Access")
          end

          def task_success_notification
            ::Katello::UINotifications::Subscriptions::SCAEnableSuccess
          end

          def task_error_notification
            ::Katello::UINotifications::Subscriptions::SCAEnableError
          end
        end
      end
    end
  end
end
