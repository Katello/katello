module Orchestrate
  class World < Dynflow::World
    def trigger(action, *args, &block)
      uuid, f = super(action, *args, &block)
      Lock.owner!(User.current, uuid)
      Task.create!(uuid: uuid, action: action.name)
      return uuid, f
    end
  end
end
