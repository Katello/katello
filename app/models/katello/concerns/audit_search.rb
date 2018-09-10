module Katello
  module Concerns
    module AuditSearch
      extend ActiveSupport::Concern

      # since this class makes User class STI, we need to provide alias for auditable_type to re-enable searching
      # audits by type = user
      def auditable_type_complete_values
        super.merge(:user => 'User')
      end
    end
  end
end
