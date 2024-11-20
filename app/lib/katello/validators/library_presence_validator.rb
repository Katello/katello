module Katello
  module Validators
    class LibraryPresenceValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, N_("must contain '%s'") % "Library") if value.select { |e| e.library }.empty?
      end
    end
  end
end
