module Katello
  module Concerns
    module RemoteExecutionProxySelectorExtensions
      def strategies
        order = [super, [:registered_through]]
        order = order.reverse if Setting[:remote_execution_prefer_registered_through_proxy]
        order.reduce(:+)
      end
    end
  end
end
