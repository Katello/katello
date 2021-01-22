module Katello
  module Agent
    class DispatchHistory < Katello::Model
      self.table_name = 'katello_agent_dispatch_histories'

      serialize :result, Hash
    end
  end
end
