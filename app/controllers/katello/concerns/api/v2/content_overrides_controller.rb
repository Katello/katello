module Katello
  module Concerns
    module Api::V2::ContentOverridesController
      extend ActiveSupport::Concern

      # overriden_object => pass it either an activation key or content host
      def validate_content_overrides_enabled(content_params, overriden_object)
        value = content_params[:value].to_s.downcase

        if value.blank? || (value != "default" && ::Foreman::Cast.to_bool(value).nil?)
          fail HttpErrors::BadRequest, _("Value must either be a boolean or 'default'")
        end

        unless overriden_object.valid_content_override_label?(content_params[:content_label])
          fail HttpErrors::BadRequest, _("Invalid content label: %s") % content_params[:content_label]
        end

        override = ::Katello::ContentOverride.new(content_params[:content_label])
        if value == "default"
          override.enabled = nil
        else
          override.enabled = ::Foreman::Cast.to_bool(value) ? "1" : '0'
        end
        override
      end
    end
  end
end
