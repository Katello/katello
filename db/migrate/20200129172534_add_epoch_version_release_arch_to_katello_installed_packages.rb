class AddEpochVersionReleaseArchToKatelloInstalledPackages < ActiveRecord::Migration[5.2]
  def up
    add_column :katello_installed_packages, :nvrea, :string
    add_column :katello_installed_packages, :epoch, :string
    add_column :katello_installed_packages, :version, :string
    add_column :katello_installed_packages, :release, :string
    add_column :katello_installed_packages, :arch, :string

    epoch_non_0 = ::Katello::Rpm.where.not(epoch: [0, nil]).pluck(:nvra, :epoch).to_h
    installed_packages = []

    ::Katello::InstalledPackage.reset_column_information
    ::Katello::InstalledPackage.find_each do |pkg|
      epoch = epoch_non_0[pkg.nvra] || "0"

      attributes_hash = ::Katello::Util::Package.parse_nvrea(pkg.nvra)
      attributes_hash[:epoch] = epoch
      attributes_hash[:nvra] = pkg.nvra
      if epoch == "0"
        attributes_hash[:nvrea] = pkg.nvra
      else
        attributes_hash[:nvrea] = "#{pkg.name}-#{epoch}:#{attributes_hash[:version]}-"\
                                  "#{attributes_hash[:release]}.#{attributes_hash[:arch]}"
      end

      installed_packages << ::Katello::InstalledPackage.new(attributes_hash)
    end
    ::Katello::InstalledPackage.import(installed_packages, validate: false, batch_size: 50_000,
                                       on_duplicate_key_update: {conflict_target: [:nvra],
                                                                 columns: [:nvrea, :epoch, :version, :release, :arch]})
  end

  def down
    remove_column :katello_installed_packages, :nvrea, :string
    remove_column :katello_installed_packages, :epoch, :string
    remove_column :katello_installed_packages, :version, :string
    remove_column :katello_installed_packages, :release, :string
    remove_column :katello_installed_packages, :arch, :string
  end
end
