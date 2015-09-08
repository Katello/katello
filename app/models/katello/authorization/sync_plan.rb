module Katello
  module Authorization::SyncPlan
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_sync_plans)
    end

    def editable?
      authorized?(:edit_sync_plans)
    end

    def deletable?
      authorized?(:destroy_sync_plans)
    end

    module ClassMethods
      def readable
        authorized(:view_sync_plans)
      end
    end
  end
end
