module Actions
  class World < Dynflow::World
    def trigger(action, *args, &block)
      dynflow_task = super(action, *args, &block)
      ::Katello::Lock.owner!(User.current, dynflow_task.id)
      ::Katello::Task.create!(uuid: dynflow_task.id, action: action.name)
      return dynflow_task
    end
  end
end
