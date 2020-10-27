module Katello
  module Concerns
    module RegistrationControllerExtensions
      extend ActiveSupport::Concern

      included do
        before_action :format_activation_key, only: [:create]
      end

      def format_activation_key
        return if params[:activation_key].blank?
        params[:activation_key] = params[:activation_key].split(',').map(&:strip).reject(&:blank?).join(',')
      end
    end
  end
end
