module Katello
  class InstalledDeb < Katello::Model
    apipie :class, desc: "A class representing #{model_name.human} object" do
      name 'Installed Deb'
      refs 'InstalledDeb'
      sections only: %w[all additional]
      property :name, String, desc: 'Returns name of the package'
      property :version, String, desc: 'Returns package version'
      property :architecture, String, desc: 'Returns package architecture'
    end
    class Jail < Safemode::Jail
      allow :name, :version, :architecture
    end

    has_many :host_installed_debs, :class_name => "Katello::HostInstalledDeb", :dependent => :destroy, :inverse_of => :installed_deb
    has_many :hosts, :through => :host_installed_debs, :class_name => "::Host"

    scoped_search :on => :id, :complete_value => true
    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :version
    scoped_search :on => :architecture
  end
end
