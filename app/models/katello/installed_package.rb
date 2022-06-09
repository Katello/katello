module Katello
  class InstalledPackage < Katello::Model
    apipie :class, desc: "A class representing #{model_name.human} object" do
      name 'Installed Package'
      refs 'InstalledPackage'
      sections only: %w[all additional]
      property :name, String, desc: 'Returns name of the package'
      property :nvra, String, desc: 'Returns package name with version, release and architecture'
      property :nvrea, String, desc: 'Returns package name with version, release, epoch and architecture'
    end
    class Jail < Safemode::Jail
      allow :nvra, :nvrea, :name
    end

    has_many :host_installed_packages, :class_name => "Katello::HostInstalledPackage", :dependent => :destroy, :inverse_of => :installed_package
    has_many :hosts, :through => :host_installed_packages, :class_name => "::Host"

    scoped_search :on => :id, :complete_value => true
    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :nvrea
    scoped_search :on => :nvra
    scoped_search :on => :epoch
    scoped_search :on => :version
    scoped_search :on => :release
    scoped_search :on => :arch
    scoped_search :on => :vendor, :complete_value => true
  end
end
