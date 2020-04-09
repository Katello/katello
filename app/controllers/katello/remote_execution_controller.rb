module Katello
  if Katello.with_remote_execution?
    class RemoteExecutionController < JobInvocationsController
      include Concerns::Api::V2::BulkHostsExtensions

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

      # to overcome the isolated namespace engine difficulties with paths
      helper Rails.application.routes.url_helpers
      def _routes
        Rails.application.routes
      end

      private

      def prepare_composer
        JobInvocationComposer.for_feature(feature_name, hosts, inputs)
      end

      def hosts
        host_ids = params[:host_ids].is_a?(String) ? params[:host_ids].split(',') : params[:host_ids]

        bulk_params = {
          included: {
            ids: host_ids,
            search: params[:scoped_search]
          }
        }

        find_bulk_hosts('edit_hosts', bulk_params)
      end

      def errata_inputs
        if params[:install_all]
          { :errata => Erratum.installable_for_hosts(hosts).pluck(:errata_id) }
        else
          { :errata => params[:name] }
        end
      end

      def inputs
        if feature_name == 'katello_errata_install'
          errata_inputs
        elsif feature_name == 'katello_service_restart'
          { :helper => params[:name] }
        elsif feature_name == 'katello_module_stream_action'
          fail HttpErrors::NotFound, _('module streams not found') if params[:module_spec].blank?
          fail HttpErrors::NotFound, _('actions not found') if params[:module_stream_action].blank?
          inputs = { :module_spec => params[:module_spec], :action => params[:module_stream_action] }
          inputs[:options] = params[:options] if params[:options]
          inputs
        else
          { :package => params[:name] }
        end
      end

      def feature_name
        # getting packageInstall from UI, translating to 'katello_package_install' feature
        "katello_#{params[:remote_action].underscore}"
      end
    end
  else
    class RemoteExecutionController < ApplicationController
    end
  end
end
