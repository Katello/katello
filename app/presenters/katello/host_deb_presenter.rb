module Katello
  class HostDebPresenter < SimpleDelegator
    attr_accessor :installed_package, :upgradable_versions, :deb_id

    def initialize(installed_package, upgradable_versions, deb_id)
      @installed_package = installed_package
      @upgradable_versions = upgradable_versions
      @deb_id = deb_id
      super(@installed_package)
    end

    def self.with_latest(packages, host)
      upgradable_packages_map = ::Katello::Deb.installable_for_hosts([host]).select(:id, :name, :architecture, :version).order(version: :desc).group_by { |i| [i.name, i.architecture] }
      installed_packages_map = ::Katello::Deb.where(version: packages.map(&:version)).select(:id, :architecture, :name).group_by { |i| [i.name, i.architecture] }

      packages.map do |p|
        upgrades = upgradable_packages_map[[p.name, p.architecture]]&.pluck(:version)
        installed = installed_packages_map[[p.name, p.architecture]]&.first&.id
        HostDebPresenter.new(p, upgrades, installed)
      end
    end
  end
end
