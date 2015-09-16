module Katello
  module Concerns
    module OperatingsystemsControllerExtensions
      extend ActiveSupport::Concern

      def available_kickstart_repo
        host = Host.new
        operatingsystem = Operatingsystem.find(params[:id])
        host.operatingsystem = operatingsystem
        host.architecture = Architecture.find(params[:architecture_id])
        host.content_aspect.new(:lifecycle_environment => Katello::KTEnvironment.find(params[:lifecycle_environment_id]),
                                :content_view => Katello::ContentView.find(params[:content_view_id]))
        host.content_source = SmartProxy.find(params[:content_source_id])

        if operatingsystem.is_a?(Redhat)
          render :json => operatingsystem.kickstart_repo(host)
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
