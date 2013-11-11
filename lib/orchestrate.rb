module Orchestrate
  require 'orchestrate/world'

  def self.world
    return @world if @world

    db_config            = ActiveRecord::Base.configurations[Rails.env]
    db_config['adapter'] = 'postgres' if db_config['adapter'] == 'postgresql'
    world_options        = {
        logger_adapter:      Dynflow::LoggerAdapters::Delegator.new(Logging.logger['action'],
                                                                    Logging.logger['dynflow']),
        executor_class:      Dynflow::Executors::Parallel, # TODO configurable Parallel or Remote
        pool_size:           5,
        persistence_adapter: Dynflow::PersistenceAdapters::Sequel.new(db_config),
        transaction_adapter: Dynflow::TransactionAdapters::ActiveRecord.new }

    @world = Orchestrate::World.new(world_options).tap do |world|
      ActionDispatch::Reloader.to_prepare { world.reload! }
      at_exit { @world.terminate!.wait }
    end
  end

  def self.trigger(action, *args, &block)
    world.trigger action, *args, &block
  end

  def self.eager_load_paths
    %W( #{Rails.root}/app/lib/orchestrate
        #{Rails.root}/app/lib/headpin/actions
        #{Rails.root}/app/lib/katello/actions )

  end

  def self.eager_load!
    eager_load_paths.each do |load_path|
      matcher = /\A#{Regexp.escape(load_path)}\/(.*)\.rb\Z/
      Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
        require_dependency file.sub(matcher, '\1')
      end
    end
  end
end
