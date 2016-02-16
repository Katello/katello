module Katello
  if Katello.with_remote_execution?
    class RemoteExecutionController < JobInvocationsController
      def new
        @composer = prepare_composer
      end

      def create
        @composer = prepare_composer
        if params[:customize] != 'true' && @composer.save
          @composer.trigger
          redirect_to job_invocation_path(@composer.job_invocation)
        else
          render :action => 'new'
        end
      end

      private

      def prepare_composer
        JobInvocationComposer.for_feature(feature_name, hosts, inputs)
      end

      def hosts
        if params[:scoped_search].present?
          params[:scoped_search]
        else
          ::Host.where(:id => params[:host_ids])
        end
      end

      def inputs
        if feature_name == 'katello_errata_install'
          { :errata => params[:name] }
        else
          { :package => params[:name] }
        end
      end

      def feature_name
        # getting packageInstall from UI, translating to 'katello_package_install' feature
        "katello_#{params[:remote_action].underscore}"
      end

      # to overcome the isolated namespace engine difficulties with paths
      helper Rails.application.routes.url_helpers
      def _routes
        Rails.application.routes
      end
    end
  else
    class RemoteExecutionController < ApplicationController
    end
  end
end
