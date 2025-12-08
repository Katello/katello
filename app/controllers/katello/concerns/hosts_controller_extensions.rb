module Katello
  module Concerns
    module HostsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers

      module Overrides
        DEFAULT_KATELLO_COLUMNS = [:installable_updates, :content_view_environments, :registered_at, :last_checkin].freeze

        def action_permission
          case params[:action]
          when 'change_content_source'
            'edit'
          else
            super
          end
        end

        def csv_pagelets
          base_pagelets = super
          # Only append Katello pagelets for /new/hosts.csv
          return base_pagelets unless request.path.start_with?('/new/hosts')

          # Get Katello pagelets from the :content profile
          if @selected_columns
            # User has customized columns - use their selection
            katello_pagelets = Pagelets::Manager.pagelets_at('hosts/_list', 'hosts_table_column_header', profile: :content, filter: { selected: @selected_columns })
          else
            # No customization - use default Katello columns matching content_hosts method
            all_katello_pagelets = Pagelets::Manager.pagelets_at('hosts/_list', 'hosts_table_column_header', profile: :content)
            katello_pagelets = all_katello_pagelets.select { |p| DEFAULT_KATELLO_COLUMNS.include?(p.opts[:key]) }
          end

          # Exclude pagelets that are already in base (like :name which uses use_pagelet)
          existing_keys = base_pagelets.map { |p| p.opts[:key] }
          katello_pagelets = katello_pagelets.reject { |p| existing_keys.include?(p.opts[:key]) }

          base_pagelets + katello_pagelets
        end
      end

      included do
        prepend Overrides

        def included_associations(include = [])
          base_associations = super
          # Only add Katello associations for /new/hosts.csv
          return base_associations unless request.path.start_with?('/new/hosts')

          katello_associations = [:host_traces, :subscription_facet, :content_facet,
                                  :applicable_rpms, :content_view_environments]
          katello_associations + base_associations
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
