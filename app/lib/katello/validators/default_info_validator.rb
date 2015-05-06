module Katello
  module Validators
    class DefaultInfoValidator < ActiveModel::EachValidator
      MAX_SIZE = 256

      def validate_each(record, attribute, value)
        if value.class == ActiveRecord::AttributeMethods::Serialization::Attribute
          value = value.unserialized_value
        end

        value.each_key do |type|
          value[type].each do |key|
            if key.blank?
              if record.errors[attribute] << _("cannot contain blank keynames")
                return
              end
            end
            if key.size >= MAX_SIZE
              if record.errors[attribute] << _("must be less than %d characters") % MAX_SIZE
                return
              end
            end
          end
        end
      end
    end
  end
end
