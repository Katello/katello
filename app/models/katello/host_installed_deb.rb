module Katello
  class HostInstalledDeb < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :host, :inverse_of => :host_installed_debs, :class_name => '::Host::Managed'
    belongs_to :installed_deb, :inverse_of => :host_installed_debs, :class_name => 'Katello::InstalledDeb'
  end
end
