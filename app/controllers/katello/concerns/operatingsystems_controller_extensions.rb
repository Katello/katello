module Katello
  module Concerns
    module OperatingsystemsControllerExtensions
      extend ActiveSupport::Concern

      def available_kickstart_repo
        host = ::Host.new
        host.operatingsystem = Operatingsystem.find(params[:id])
        host.architecture = Architecture.find(params[:architecture_id])

        lifecycle_env = Katello::KTEnvironment.find(params[:lifecycle_environment_id])
        content_view = Katello::ContentView.find(params[:content_view_id])
        host.content_facet = Host::ContentFacet.new(:lifecycle_environment_id => lifecycle_env.id,
                                                    :content_view_id => content_view.id)
        host.content_source = SmartProxy.find(params[:content_source_id])

        if  host.operatingsystem.is_a?(Redhat)
          render :json =>  host.operatingsystem.kickstart_repo(host)
        else
          render :json => nil
        end
      end

      def action_permission
        case params[:action]
        when 'available_kickstart_repo'
          'view'
        else
          super
        end
      end
    end
  end
end
