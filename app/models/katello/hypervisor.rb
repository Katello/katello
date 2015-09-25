module Katello
  class Hypervisor < System
    validates_lengths_from_database

    UNSUPPORTED_ACTIONS = [:package_profile, :pulp_facts, :simple_packages, :errata, :del_pulp_consumer, :set_pulp_consumer,
                           :update_pulp_consumer, :upload_package_profile, :install_package, :uninstall_package,
                           :update_package, :install_package_group, :uninstall_package_group]

    UNSUPPORTED_ACTIONS.each do |unsupported_action|
      define_method(unsupported_action) do
        fail Errors::UnsupportedActionException.new(unsupported_action, self, _("Hypervisor does not support this action"))
      end
    end
  end
end
