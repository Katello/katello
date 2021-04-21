module Actions
  module Katello
    class BulkAgentAction < Actions::BulkAction
      def plan(agent_action, hosts, args)
        host_ids = hosts.map(&:id)

        histories = ::Katello::Agent::Dispatcher.create_histories(
          host_ids: host_ids
        )

        grouped_histories = {}
        histories.each { |h| grouped_histories[h.host_id] = h.id }
        options = {
          dispatch_histories: grouped_histories,
          type: agent_action.agent_message,
          content: args[:content],
          bulk: true
        }
        super(agent_action, hosts, options)
      end

      def spawn_plans
        args = input[:args].first
        histories = ::Katello::Agent::DispatchHistory.where(id: args[:dispatch_histories].slice(*current_batch.map(&:to_s)).values)
        ::Katello::Agent::Dispatcher.dispatch(
          args[:type].to_sym,
          histories,
          content: args[:content]
        )
        super
      end
    end
  end
end
