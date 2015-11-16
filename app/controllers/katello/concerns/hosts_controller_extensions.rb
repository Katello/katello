module Katello
  module Concerns
    module HostsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers
      included do
        before_filter :find_host, :only => [:package_profile]

        def destroy
          sync_task(::Actions::Katello::Host::Destroy, @host)
          process_success(:success_redirect => hosts_path)
        rescue StandardError => ex
          process_error(:object => @host, :error_msg => ex.message)
        end

        def submit_multiple_destroy
          task = async_task(::Actions::BulkAction, ::Actions::Katello::Host::Destroy, @hosts)
          redirect_to(foreman_tasks_task_path(task.id))
        end

        def puppet_environment_for_content_view
          view = Katello::ContentView.find(params[:content_view_id])
          environment = Katello::KTEnvironment.find(params[:lifecycle_environment_id])
          version = view.version(environment)
          cvpe = Katello::ContentViewPuppetEnvironment.where(:environment_id => environment, :content_view_version_id => version).first
          render :json => cvpe.nil? ? nil : {:name => cvpe.puppet_environment.name, :id => cvpe.puppet_environment.id}
        end
      end
    end
  end
end
