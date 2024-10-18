module Katello
  module Validators
    class PriorValidator < ActiveModel::Validator
      def validate(record)
        # need to ensure that prior
        # environment already does not have a successor
        # this is because in v1.0 we want
        # prior to have only one child (unless its the Library)
        ancestor = record.prior
        if ancestor && !ancestor.library? && (ancestor.successors.count == 1 && !ancestor.successors.include?(record))
          record.errors.add(:prior, _("prior environment can only have one child"))
        end
      end
    end
  end
end
