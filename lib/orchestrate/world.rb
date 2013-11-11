module Orchestrate
  class World < Dynflow::World
    def trigger(action, *args, &block)
      uuid, f = super(action, *args, &block)
      DynflowTask.create!(uuid: uuid, action: action.name, user_id: User.current.id) do |task|
        # to set additional task meta-data
        block.call task if block
      end
      return uuid, f
    end
  end
end
