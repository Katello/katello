module Katello
  class InstalledDeb < Katello::Model
    has_many :host_installed_debs, :class_name => "Katello::HostInstalledDeb", :dependent => :destroy, :inverse_of => :installed_deb
    has_many :hosts, :through => :host_installed_debs, :class_name => "::Host"

    scoped_search :on => :id, :complete_value => true
    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version
    scoped_search :on => :architecture
  end
end
