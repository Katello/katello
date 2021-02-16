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
          if params[:action] == 'pulp_status' || params[:action] == 'pulp_storage'
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
        before_action :find_resource_and_status, :only => [:pulp_storage, :pulp_status]

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

        def pulp_status
          pulp_connection = @proxy_status[:pulp] || @proxy_status[:pulpnode]
          @pulp_status = pulp_connection.status
          if @pulp_status['fatal']
            Rails.logger.warn @pulp_status['fatal']
            respond_to do |format|
              format.html { render :plain => _('Error connecting to Pulp service') }
              format.json { render :json => {:success => false, :message => @pulp_status['fatal']} }
            end
          else
            respond_to do |format|
              format.html { render :layout => false }
              format.json { render :json => {:success => true, :message => @pulp_status} }
            end
          end
        end
      end

      private

      def find_resource_and_status
        find_resource
        find_status
      end
    end
  end
end
