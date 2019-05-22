module Katello
  module Concerns
    module HostsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers

      module Overrides
        def action_permission
          case params[:action]
          when 'content_hosts'
            'view'
          else
            super
          end
        end
      end

      included do
        prepend Overrides

        def destroy
          if Katello::RegistrationManager.unregister_host(@host, :unregistering => false)
            process_success(:success_redirect => hosts_path)
          else
            process_error :redirect => :back, :error_msg => _("Failed to delete %{host}: %{errors}") % { :host => @host, :errors => @host.errors.full_messages }
          end
        rescue StandardError => ex
          process_error(:object => @host, :error_msg => ex.message, :redirect => saved_redirect_url_or(send("#{controller_name}_url")))
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

        def content_hosts
          respond_to do |format|
            format.csv do
              @hosts = resource_base_with_search.where(organization_id: params[:organization_id])
                         .preload(:subscription_facet, :host_statuses, :operatingsystem,
                                  :applicable_rpms, :lifecycle_environment, :content_view)
              csv_response(@hosts,
                [:name, :subscription_status_label, 'content_facet.installable_security_errata_count',
                 'content_facet.installable_bugfix_errata_count', 'content_facet.installable_enhancement_errata_count',
                 'content_facet.upgradable_rpm_count', :operatingsystem, :lifecycle_environment, :content_view,
                 'subscription_facet.registered_at', 'subscription_facet.last_checkin'],
                ['Name', 'Subscription Status', 'Installable Updates - Security',
                 'Installable Updates - Bug Fixes', 'Installable Updates - Enhancements',
                 'Installable Updates - Package Count', 'OS', 'Environment', 'Content View',
                 'Registered', 'Last Checkin'])
            end
          end
        end
      end
    end
  end
end
