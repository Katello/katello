module Orchestrate
  def self.world
    return @world if @world

    db_config = ActiveRecord::Base.configurations[Rails.env]
    db_config['adapter'] = 'postgres' if db_config['adapter'] == 'postgresql'
    world_options =
        { executor_class:      Dynflow::Executors::Parallel,
          pool_size:           5,
          persistence_adapter: Dynflow::PersistenceAdapters::Sequel.new(db_config),
          transaction_adapter: Dynflow::TransactionAdapters::ActiveRecord.new }

    @world = Orchestrate::World.new(world_options).tap do
      at_exit { @world.terminate!.wait }
    end
  end

  def self.trigger(action, *args)
    uuid, f = world.trigger(action, *args)
    DynflowTask.create!(uuid: uuid, action: action.name, user_id: User.current.id) do |task|
      # to set additional task meta-data
      yield task if block_given?
    end
    return uuid, f
  end
end
