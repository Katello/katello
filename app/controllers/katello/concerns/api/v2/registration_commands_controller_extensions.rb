module Katello
  module Concerns
    module Api
      module V2
        module RegistrationCommandsControllerExtensions
          module ApipieExtensions
            extend ::Apipie::DSL::Concern

            update_api(:create) do
              param :registration_command, Hash do
                param :activation_key, String, desc: N_('Activation key(s) for Subscription Manager. Required for CentOS and Red Hat Enterprise Linux. Multiple keys add separated by comma, example: key1,key2,key3.')
              end
            end
          end

          extend ActiveSupport::Concern

          included do
            include ApipieExtensions
            before_action :format_activation_key
          end

          def format_activation_key
            return if registration_params[:activation_key].blank?
            registration_params[:activation_key] = registration_params[:activation_key].split(',').map(&:strip).reject(&:blank?).join(',')
          end
        end
      end
    end
  end
end
