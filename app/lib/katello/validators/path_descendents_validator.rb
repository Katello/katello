module Katello
  module Validators
    class PathDescendentsValidator < ActiveModel::Validator
      def validate(record)
        #need to ensure that
        #environment is not duplicated in its path
        # We do not want circular dependencies
        return if record.prior.nil?
        record.errors.add(:prior, _(" environment cannot be set to an environment already on its path")) if duplicate? record.prior
      end

      def duplicate?(record)
        s = record.successor
        ret = [record.id]
        until s.nil?
          return true if ret.include? s.id
          ret << s.id
          s = s.successor
        end
        false
      end
    end
  end
end
