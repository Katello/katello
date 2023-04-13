module Katello
  module Concerns
    module ContentViewFilterRuleCommon
      extend ActiveSupport::Concern

      included do
        scoped_search on: :id, :complete_value => true
        scoped_search on: :name, :complete_value => true
        after_create -> { create_audit_record('create') }
        after_update -> { create_audit_record('update') }
        before_destroy -> { create_audit_record('destroy') }

        validates_lengths_from_database
      end

      def create_audit_record(action)
        audit = case action
                when 'create'
                  Audit.new(
                    auditable_type: self.class,
                    auditable_id: id,
                    user_id: User.current.id,
                    user_type: 'User',
                    audited_changes: self.as_json,
                    associated_id: filter.content_view.id,
                    associated_type: filter.content_view.class,
                    action: action
                  )
                when 'update'
                  Audit.new(
                    auditable_type: self.class,
                    auditable_id: id,
                    user_id: User.current.id,
                    user_type: 'User',
                    audited_changes: self.previous_changes,
                    associated_id: filter.content_view.id,
                    associated_type: filter.content_view.class,
                    action: action
                  )
                when 'destroy'
                  Audit.new(
                    auditable_type: self.class,
                    auditable_id: id,
                    user_id: User.current.id,
                    user_type: 'User',
                    audited_changes: self.as_json,
                    associated_id: filter.content_view.id,
                    associated_type: filter.content_view.class,
                    action: action
                  )
                end
        audit&.save!
      end
    end
  end
end
