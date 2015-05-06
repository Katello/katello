module Katello
  module Validators
    class PriorValidator < ActiveModel::Validator
      def validate(record)
        #need to ensure that prior
        #environment already does not have a successor
        #this is because in v1.0 we want
        # prior to have only one child (unless its the Library)
        has_no_prior = true
        if record.organization
          has_no_prior = record.organization.kt_environments.reject { |env| env == record || env.prior != record.prior || env.prior == env.organization.library }.empty?
        end
        record.errors[:prior] << _("environment can only have one child") unless has_no_prior

        # only Library can have prior=nil
        record.errors[:prior] << _("environment required") unless !record.prior.nil? || record.library?
      end
    end
  end
end
