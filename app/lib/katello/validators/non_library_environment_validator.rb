module Katello
  module Validators
    class NonLibraryEnvironmentValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        return unless value
        record.errors.add(attribute, N_("Cannot register a system to the '%s' environment") % "Library") if !record.environment.nil? && record.environment.library?
      end
    end
  end
end
