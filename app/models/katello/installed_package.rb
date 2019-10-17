module Katello
  class InstalledPackage < Katello::Model
    class Jail < Safemode::Jail
      allow :nvra, :nvrea, :name
    end

    has_many :hosts, :through => :host_installed_packages, :class_name => "::Host"
    has_many :host_installed_packages, :class_name => "Katello::HostInstalledPackage", :dependent => :destroy, :inverse_of => :installed_package

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :nvra

    def nvrea
      nvra
    end
  end
end
