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
        end
      end
    end
  end
end
