module Katello
  class HostPackagePresenter < SimpleDelegator
    attr_accessor :installed_package, :upgradable_versions, :rpm_id

    def initialize(installed_package, upgradable_versions, rpm_id)
      @installed_package = installed_package
      @upgradable_versions = upgradable_versions
      @rpm_id = rpm_id
      super(@installed_package)
    end

    def self.with_latest(packages, host)
      upgradable_packages_map = ::Katello::Rpm.installable_for_hosts([host]).select(:id, :name, :arch, :nvra, :evr).order(evr: :desc).group_by { |i| [i.name, i.arch] }
      installed_packages_map = ::Katello::Rpm.where(nvra: packages.map(&:nvra)).select(:id, :arch, :name).group_by { |i| [i.name, i.arch] }

      packages.map do |p|
        upgrades = upgradable_packages_map[[p.name, p.arch]]&.pluck(:nvra)
        installed = installed_packages_map[[p.name, p.arch]]&.first&.id
        HostPackagePresenter.new(p, upgrades, installed)
      end
    end
  end
end
