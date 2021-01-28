module Katello
  module Agent
    class DispatchHistory < Katello::Model
      self.table_name = 'katello_agent_dispatch_histories'

      serialize :result, Hash

      def accepted?
        accepted_at.present?
      end

      def finished?
        result.present?
      end
    end
  end
end
