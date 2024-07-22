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
          when 'change_content_source'
            'edit'
          else
            super
          end
        end
      end

      included do
        prepend Overrides

        def included_associations(include = [])
          [:host_traces] + super
        end

        def update_multiple_taxonomies(type)
          if type == :organization
            new_org_id = params.dig(type, 'id')

            if new_org_id
              registered_host = @hosts.where.not(organization_id: new_org_id).joins(:subscription_facet).first
              if registered_host
                error _("Unregister host %s before assigning an organization") % registered_host.name
                redirect_back_or_to hosts_path
                return
              end
            end
          end

          super
        end

        def destroy
          if Katello::RegistrationManager.unregister_host(@host, :unregistering => false)
            process_success redirection_url_on_host_deletion
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

        def content_hosts
          respond_to do |format|
            format.csv do
              @hosts = resource_base_with_search.where(organization_id: params[:organization_id])
                         .preload(:subscription_facet, :host_statuses, :operatingsystem,
                                  :applicable_rpms, :content_view_environments)
              csv_response(@hosts,
                [:name, 'content_facet.installable_security_errata_count',
                 'content_facet.installable_bugfix_errata_count', 'content_facet.installable_enhancement_errata_count',
                 'content_facet.upgradable_rpm_count', :operatingsystem, :content_view_environment_names,
                 'subscription_facet.registered_at', 'subscription_facet.last_checkin'],
                ['Name', 'Installable Updates - Security',
                 'Installable Updates - Bug Fixes', 'Installable Updates - Enhancements',
                 'Installable Updates - Package Count', 'OS', 'Content View Environments',
                 'Registered', 'Last Checkin'])
            end
          end
        end

        def change_content_source_data
          hosts = params[:search].presence ? ::Host.search_for(params[:search]) : ::Host.where(id: params[:host_ids])
          content_hosts = []
          hosts_without_content = []

          hosts.each do |host|
            if host.content_facet
              content_hosts << { id: host.id, name: host.name }
            else
              hosts_without_content << { id: host.id, name: host.name }
            end
          end

          content_sources = SmartProxy.authorized(:view_smart_proxies)
                                      .with_content
                                      .includes([:smart_proxy_features])
                                      .joins(:lifecycle_environments)
                                      .distinct

          template_id = RemoteExecutionFeature.feature!(:katello_change_content_source).job_template_id
          job_invocation_path = new_job_invocation_path(template_id: template_id, host_ids: content_hosts.map { |h| h[:id] }) if template_id

          render json: {
            content_hosts: content_hosts,
            hosts_without_content: hosts_without_content,
            content_sources: content_sources,
            job_invocation_path: job_invocation_path,
          }
        end
      end
    end
  end
end
