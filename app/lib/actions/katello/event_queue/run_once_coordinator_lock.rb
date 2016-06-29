module Actions
  module Katello
    module EventQueue
      class RunOnceCoordinatorLock < Dynflow::Coordinator::LockByWorld
        def initialize(world)
          super
          @data[:id] = 'katello-event-queue'
        end
      end
    end
  end
end
