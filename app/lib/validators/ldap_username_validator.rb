module Validators
  class LdapUsernameValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value && do_validate_ldap?(value)
        record.errors[attribute] << N_("does not exist in your current LDAP system. Please choose a different user, or contact your LDAP administrator if you think this message is in error.") if !Ldap.valid_user?(value)
      end
    end

    def do_validate_ldap?(value)
      Katello.config.warden == 'ldap' &&
        Katello.config.validate_ldap &&
        value['hidden-'] == nil
    end
  end
end
