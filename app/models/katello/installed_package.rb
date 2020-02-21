module Katello
  class InstalledPackage < Katello::Model
    class Jail < Safemode::Jail
      allow :nvra, :nvrea, :name
    end

    has_many :hosts, :through => :host_installed_packages, :class_name => "::Host"
    has_many :host_installed_packages, :class_name => "Katello::HostInstalledPackage", :dependent => :destroy, :inverse_of => :installed_package

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :nvrea
    scoped_search :on => :nvra
    scoped_search :on => :epoch
    scoped_search :on => :version
    scoped_search :on => :release
    scoped_search :on => :arch
  end
end
