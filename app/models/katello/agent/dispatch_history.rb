module Katello
  module Agent
    class DispatchHistory < Katello::Model
      self.table_name = 'katello_agent_dispatch_histories'

      serialize :status, Hash
    end
  end
end
