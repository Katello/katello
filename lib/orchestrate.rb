module Orchestrate
  require 'orchestrate/world'

  files = Dir.chdir(File.join(Rails.root, 'lib')) do
    Dir.glob('orchestrate/{helpers,elastic_search,katello,headpin}/**/*.rb') +
        Dir.glob('{katello,headpin}/actions/*.rb')
  end

  files.each { |f| require f }

  def self.world
    return @world if @world

    db_config            = ActiveRecord::Base.configurations[Rails.env]
    db_config['adapter'] = 'postgres' if db_config['adapter'] == 'postgresql'
    world_options        = {
        executor_class:      Dynflow::Executors::Parallel, # TODO configurable Parallel or Remote
        pool_size:           5,
        persistence_adapter: Dynflow::PersistenceAdapters::Sequel.new(db_config),
        transaction_adapter: Dynflow::TransactionAdapters::ActiveRecord.new }

    @world = Orchestrate::World.new(world_options).tap do
      at_exit { @world.terminate!.wait }
    end
  end

  def self.trigger(action, *args, &block)
    world.trigger action, *args, &block
  end
end
