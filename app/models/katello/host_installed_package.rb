module Katello
  class HostInstalledPackage < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :host, :inverse_of => :host_installed_packages, :class_name => '::Host::Managed'
    belongs_to :installed_package, :inverse_of => :host_installed_packages, :class_name => 'Katello::InstalledPackage'
  end
end
