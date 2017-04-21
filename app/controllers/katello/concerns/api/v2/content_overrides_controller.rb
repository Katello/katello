module Katello
  module Concerns
    module Api::V2::ContentOverridesController
      extend ActiveSupport::Concern

      # overriden_object => pass it either an activation key or content host
      def validate_content_overrides_enabled(content_params, overriden_object = nil)
        name = content_params[:name] || "enabled"
        compare_value = content_params[:value].to_s.downcase
        remove = content_params.key?(:remove) ? ::Foreman::Cast.to_bool(content_params[:remove]) : nil
        content_label = content_params[:content_label]

        if !remove && name == "enabled" &&
                       (compare_value.blank? || (compare_value != "default" &&
                        ::Foreman::Cast.to_bool(compare_value).nil?))
          fail HttpErrors::BadRequest, _("Value must either be a boolean or 'default' for 'enabled'")
        end

        if content_label.blank? || (overriden_object &&
                                    !overriden_object.valid_content_override_label?(content_label))
          fail HttpErrors::BadRequest, _("Invalid content label: %s") % content_params[:content_label]
        end

        override = ::Katello::ContentOverride.new(content_params[:content_label])
        override.name = name
        if remove || (name == "enabled" && compare_value == "default")
          override.value = nil
        else
          if name == "enabled"
            override.value = ::Foreman::Cast.to_bool(compare_value) ? "1" : "0"
          else
            override.value = content_params[:value]
          end
        end
        override
      end
    end
  end
end
