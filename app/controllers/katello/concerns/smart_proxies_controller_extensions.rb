module Katello
  module Concerns
    module SmartProxiesControllerExtensions
      extend ActiveSupport::Concern

      module Overrides
        def show
          @task_search_url = main_app.foreman_tasks_tasks_path(:search => "resource_id = #{@smart_proxy.id} AND resource_type = #{@smart_proxy.class}")
          render 'foreman/smart_proxies/show', :layout => 'katello/layouts/foreman_with_bastion'
        end

        def action_permission
          if params[:action] == 'pulp_storage'
            :view
          else
            super
          end
        end
      end

      included do
        prepend Overrides
        helper 'bastion/layout'

        append_view_path('app/views/foreman')
        before_action :find_resource, :only => [:pulp_storage]

        def pulp_storage
          @storage = @smart_proxy.pulp_disk_usage
          respond_to do |format|
            format.html { render :layout => false }
            format.json { render :json => {:success => true, :message => @storage} }
          end
        rescue ::Foreman::WrappedException => e
          Rails.logger.warn _('Error connecting. Got: %s') % e
          respond_to do |format|
            format.html { render :plain => _('Error retrieving Pulp storage') }
            format.json { render :json => {:success => false, :message => e} }
          end
        end
      end
    end
  end
end
