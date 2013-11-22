module Actions
  class Base
    def self.eager_load_paths
      %W[#{Katello::Engine.root}/app/lib/actions
         #{Katello::Engine.root}/app/lib/headpin/actions
         #{Katello::Engine.root}/app/lib/katello/actions ]
    end

    def self.eager_load!
      eager_load_paths.each do |load_path|
        # TODO: does the reloading work now?
        Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
          require_dependency file
        end
      end
    end

    def world
      return @world if @world

      @world = create_world_instance(::Katello.config.dynflow.remote)

      ActionDispatch::Reloader.to_prepare { @world.reload! }
      at_exit { @world.terminate!.wait }

      return @world
    end

    def trigger(action, *args, &block)
      world.trigger action, *args, &block
    end

    def create_world_instance(remote)
      db_config            = ActiveRecord::Base.configurations[Rails.env]
      db_config['adapter'] = 'postgres' if db_config['adapter'] == 'postgresql'

      Actions::World.new(
          logger_adapter:
              Dynflow::LoggerAdapters::Delegator.new(Logging.logger['action'], Logging.logger['dynflow']),
          persistence_adapter:
              Dynflow::PersistenceAdapters::Sequel.new(db_config),
          transaction_adapter:
              Dynflow::TransactionAdapters::ActiveRecord.new
      ) do |world|
        { executor: if remote
                      Dynflow::Executors::RemoteViaSocket.new(world, ::Katello.config.dynflow.socket_path)
                    else
                      Dynflow::Executors::Parallel.new(world, ::Katello.config.dynflow.pool_size)
                    end }
      end
    end
  end
end
