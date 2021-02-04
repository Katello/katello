module Actions
  module Katello
    class BulkAgentAction < Actions::BulkAction
      def plan(agent_action, hosts, args)
        host_ids = hosts.map(&:id)
        dispatch_args = {
          content: args[:content]
        }
        histories = ::Katello::Agent::Dispatcher.dispatch(agent_action.agent_message, host_ids, dispatch_args)

        grouped_histories = {}
        histories.each { |h| grouped_histories[h.host_id] = h.id }
        options = {
          dispatch_histories: grouped_histories,
          content: args[:content]
        }
        super(agent_action, hosts, options)
      end
    end
  end
end
