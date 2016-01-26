module Katello
  module Concerns
    module SmartProxiesControllerExtensions
      extend ActiveSupport::Concern

      included do
        append_view_path('app/views/foreman')
        before_filter :find_resource_and_status, :only => [:pulp_storage, :pulp_status]
        alias_method_chain :action_permission, :katello

        def pulp_storage
          @storage = @proxy_status[:pulp].storage
          respond_to do |format|
            format.html { render :layout => false }
            format.json { render :json => {:success => true, :message => @storage} }
          end
        rescue ::Foreman::WrappedException => e
          Rails.logger.warn _('Error connecting. Got: %s') % e
          respond_to do |format|
            format.html { render :text =>  _('Error retrieving Pulp storage') }
            format.json { render :json => {:success => false, :message => e} }
          end
        end

        def pulp_status
          @pulp_status = @proxy_status[:pulp].status
          if @pulp_status['fatal']
            Rails.logger.warn @pulp_status['fatal']
            respond_to do |format|
              format.html { render :text =>  _('Error connecting to Pulp service') }
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

      def action_permission_with_katello
        if params[:action] == 'pulp_status' || params[:action] == 'pulp_storage'
          :view
        else
          action_permission_without_katello
        end
      end
    end
  end
end
