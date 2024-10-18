module Katello
  module Validators
    class ContentViewFilterVersionValidator < ActiveModel::Validator
      def validate(record)
        if !record.version.blank? && (!record.min_version.blank? || !record.max_version.blank?)
          invalid_parameters = _("Invalid filter rule specified, 'version' cannot be specified in the" \
                                 " same tuple as 'min_version' or 'max_version'")
          record.errors.add(:base, invalid_parameters)
        end
      end
    end
  end
end
