class InstalledPackageUniqueNvrea < ActiveRecord::Migration[5.2]
  def fix_missing_attributes
    #bug in dynflow may have resulted in old code running and not properly populating fields
    # This block is basically copied from 20200129172534_add_epoch_version_release_arch_to_katello_installed_packages.rb
    epoch_non_0 = ::Katello::Rpm.where.not(epoch: [0, nil]).pluck(:nvra, :epoch).to_h
    installed_packages = []
    ::Katello::InstalledPackage.where(:nvrea => nil).each do |pkg|
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

  def consolidate_duplicate_nvreas
    host_installed_packages = []
    deletable_installed_package_ids = []
    Katello::InstalledPackage.having('count(nvrea) > 1').group(:nvrea).pluck(:nvrea).each do |nvrea|
      found = Katello::InstalledPackage.includes(:host_installed_packages).where(:nvrea => nvrea).to_a
      to_keep = found.pop
      found.each do |duplicate|
        duplicate.host_ids.each do |host_id|
          host_installed_packages << {:installed_package_id => to_keep.id, :host_id => host_id}
        end
        deletable_installed_package_ids << duplicate.id
      end
    end
    if host_installed_packages.any?
      Katello::HostInstalledPackage.import(host_installed_packages, validate: false, on_duplicate_key_ignore: true)
    end
    if deletable_installed_package_ids.any?
      Katello::HostInstalledPackage.where(installed_package_id: deletable_installed_package_ids).delete_all
      Katello::InstalledPackage.where(id: deletable_installed_package_ids).delete_all
    end
  end

  def up
    fix_missing_attributes
    #now there should be no NULL nvreas
    change_column :katello_installed_packages, :nvrea, :string, :null => false

    consolidate_duplicate_nvreas
    add_index "katello_installed_packages", [:nvrea], :unique => true
    remove_index "katello_installed_packages", [:nvra]
  end

  def down
    remove_index "katello_installed_packages", [:nvrea]
    add_index "katello_installed_packages", [:nvra], :unique => true
    change_column :katello_installed_packages, :nvrea, :string, :null => true
  end
end
