module Actions
  class World < Dynflow::World
    def trigger(action, *args, &block)
      uuid, f = super(action, *args, &block)
      ::Katello::Lock.owner!(User.current, uuid)
      ::Katello::Task.create!(uuid: uuid, action: action.name)
      return uuid, f
    end
  end
end
