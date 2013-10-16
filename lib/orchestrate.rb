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

    @world = Dynflow::World.new(world_options)
  end
end
