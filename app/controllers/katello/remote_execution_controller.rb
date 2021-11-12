module Katello
  if Katello.with_remote_execution?
    class RemoteExecutionController < JobInvocationsController
      include Concerns::Api::V2::BulkHostsExtensions
      include Concerns::Api::V2::HostErrataExtensions

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
        bulk_host_ids = ActiveSupport::JSON.decode(params[:bulk_host_ids]).deep_symbolize_keys

        find_bulk_hosts('edit_hosts', bulk_host_ids)
      end

      def errata_inputs
        if ::Foreman::Cast.to_bool(params[:install_all])
          Erratum.installable_for_hosts(hosts).pluck(:errata_id).join(',')
        elsif params[:bulk_errata_ids]
          find_bulk_errata_ids(hosts, params[:bulk_errata_ids]).join(',')
        else
          params[:name]
        end
      end

      def inputs
        if feature_name == 'katello_errata_install'
          { "Errata Search Query" => "errata_id ^ (#{errata_inputs.join(',')})" }
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
