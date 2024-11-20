module Katello
  module Validators
    class NotInLibraryValidator < ActiveModel::Validator
      def validate(record)
        record.errors.add(:environment, _("The '%s' environment cannot contain a changeset!") % "Library") if record.environment.library?
      end
    end
  end
end
