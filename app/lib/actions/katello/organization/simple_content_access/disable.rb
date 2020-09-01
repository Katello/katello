module Actions
  module Katello
    module Organization
      module SimpleContentAccess
        class Disable < Toggle
          def content_access_mode_value
            SIMPLE_CONTENT_ACCESS_DISABLED_VALUE
          end

          def humanized_name
            N_("Disable Simple Content Access")
          end

          def task_success_notification
            ::Katello::UINotifications::Subscriptions::SCADisableSuccess
          end

          def task_error_notification
            ::Katello::UINotifications::Subscriptions::SCADisableError
          end
        end
      end
    end
  end
end
