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
        # args[:dispatch_histories] keys are numeric host ids; they may be integer or string
        # Hash#slice will return a filtered hash only with the specified keys, and ignore keys that don't exist
        possible_keys = [*current_batch.map(&:to_i), *current_batch.map(&:to_s)]
        histories = ::Katello::Agent::DispatchHistory.where(id: args[:dispatch_histories].slice(*possible_keys).values)
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
