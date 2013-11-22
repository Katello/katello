module Actions
  class DelayedWorkerInjectorImpl
    attr_reader :delayed_jobs_worker_class

    def initialize(delay_jobs_worker_class = Delayed::Worker)
      @delayed_jobs_worker_class = delay_jobs_worker_class
    end

    def inject_to_delayed_jobs!
      @delayed_jobs_worker_class.class_eval do
        def start_with_dynflow
          @dynflow_world    = Actions.base.create_world_instance false
          @dynflow_listener =
              Dynflow::Listeners::Socket.new(@dynflow_world,
                                             ::Katello.config.dynflow.socket_path)
          start_without_dynflow
        end
        alias_method_chain :start, :dynflow

        def stop_with_dynflow
          @dynflow_world.terminate.wait
          stop_without_dynflow
        end
        alias_method_chain :stop, :dynflow
      end
    end

    def load
      inject_to_delayed_jobs! if ::Katello.config.dynflow.remote
    end
  end

  DelayedWorkerInjector = DelayedWorkerInjectorImpl.new
end
