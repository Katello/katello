module Katello
  module Concerns
    module RegistrationCommandsControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :format_activation_key, only: [:create]
      end

      def format_activation_key
        return if registration_params[:activation_key].blank?
        registration_params[:activation_key] = registration_params[:activation_key].split(',').map(&:strip).reject(&:blank?).join(',')
      end
    end
  end
end
