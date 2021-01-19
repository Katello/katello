module Katello
  module InstalledPackageHelper
    # FIXME: if there is a modular and a non-modular RPM in the same repo with the same NEVRA, the result is ambiguous.
    # If the host has a module steam enabled with that RPM, the related InstalledPackage must be modular (right?)
    def self.associate_modularity_with_installed_packages(installed_packages)
      matching_indexed_packages = ::Katello::Rpm.where(nvra: installed_packages.map(&:nvra),
                                                       epoch: installed_packages.map(&:epoch))
      installed_packages.each do |installed_package|
        matched_indexed_package = matching_indexed_packages.detect do |indexed_package|
          indexed_package.nvra == installed_package.nvra && indexed_package.epoch == installed_package.epoch
        end
        unless matched_indexed_package.nil?
          if matched_indexed_package.new_record?
            matched_installed_package.modular = indexed_package.modular
          else
            matched_installed_package.update(modular: indexed_package.modular)
          end
        end
      end
    end

    def self.associate_modularity_with_indexed_packages(indexed_packages)
      matching_installed_packages = ::Katello::InstalledPackage.where(nvra: indexed_packages.map(&:nvra),
                                                                      epoch: indexed_packages.map(&:epoch))
      indexed_packages.each do |indexed_package|
        matched_installed_package = matching_installed_packages.detect do |installed_package|
          installed_package.nvra == indexed_package.nvra && installed_package.epoch == indexed_package.epoch
        end
        unless matched_installed_package.nil?
          if matched_installed_package.new_record?
            matched_installed_package.modular = indexed_package.modular
          else
            matched_installed_package.update(modular: indexed_package.modular)
          end
        end
      end
    end
  end
end
