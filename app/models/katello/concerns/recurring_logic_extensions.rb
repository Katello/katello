module Katello
  module Concerns
    module RecurringLogicExtensions
      extend ActiveSupport::Concern

      included do
        has_one :sync_plan, :inverse_of => :foreman_tasks_recurring_logic,
                :class_name => "Katello::SyncPlan", :dependent => :destroy,
                :foreign_key => :foreman_tasks_recurring_logic_id
      end
    end
  end
end
