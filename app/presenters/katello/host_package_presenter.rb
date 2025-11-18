module Katello
  class HostPackagePresenter < SimpleDelegator
    attr_accessor :installed_package, :upgradable_versions, :rpm_id, :persistence

    def initialize(installed_package, upgradable_versions, rpm_id, persistence = nil)
      @installed_package = installed_package
      @upgradable_versions = upgradable_versions
      @rpm_id = rpm_id
      @persistence = persistence
      super(@installed_package)
    end

    def self.package_map(packages, host, include_upgradable = false, include_persistence = false)
      upgradable_packages_map = nil
      installed_packages_map = nil
      persistence_map = nil

      if include_upgradable
        upgradable_packages_map = ::Katello::Rpm.installable_for_hosts([host]).select(:id, :name, :arch, :nvra, :evr)
          .order(evr: :desc).group_by { |i| [i.name, i.arch] }
        installed_packages_map = ::Katello::Rpm.where(nvra: packages.map(&:nvra)).select(:id, :arch, :name)
          .group_by { |i| [i.name, i.arch] }
      end
      if include_persistence
        persistence_map = ::Katello::HostInstalledPackage.where(host_id: host.id, installed_package_id: packages.map(&:id))
          .pluck(:installed_package_id, :persistence).to_h
      end

      packages.map do |p|
        nvras = upgradable_packages_map&.[]([p.name, p.arch])&.pluck(:nvra)
        id = installed_packages_map&.[]([p.name, p.arch])&.first&.id
        persistence = persistence_map&.[](p.id)
        HostPackagePresenter.new(p, nvras, id, persistence) # set nvras, id, and persistence to nil if the respective map is nil
      end
    end
  end
end
