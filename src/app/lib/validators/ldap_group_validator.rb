module Validators
  class LdapGroupValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value && Katello.config.validate_ldap
        record.errors[attribute] << N_("does not exist in your current LDAP system. Please choose a different group, or contact your LDAP administrator to have this group created") if !Ldap.valid_group?(value)
      end
    end
  end
end
