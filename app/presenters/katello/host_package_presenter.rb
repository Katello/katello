module Katello
  class HostPackagePresenter < SimpleDelegator
    attr_accessor :installed_package, :upgradable_version, :rpm_id

    def initialize(installed_package, upgradable_version, rpm_id)
      @installed_package = installed_package
      @upgradable_version = upgradable_version
      @rpm_id = rpm_id
      super(@installed_package)
    end

    def self.with_latest(packages, host)
      upgradable_packages_map = ::Katello::Rpm.installable_for_hosts([host]).select(:id, :name, :nvra, :evr).order(evr: :desc).all.group_by(&:name)
      installed_packages_map = ::Katello::Rpm.where(nvra: packages.map(&:nvra)).select(:id, :name).group_by(&:name)

      packages.map do |p|
        HostPackagePresenter.new(p, upgradable_packages_map[p.name]&.first&.nvra, installed_packages_map[p.name]&.first&.id)
      end
    end
  end
end
