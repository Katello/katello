module Katello
  class HostInstalledPackage < Katello::Model
    self.include_root_in_json = false

    belongs_to :host, :inverse_of => :host_installed_packages, :class_name => '::Host::Managed'
    belongs_to :installed_package, :inverse_of => :host_installed_packages, :class_name => 'Katello::InstalledPackage'
  end
end
