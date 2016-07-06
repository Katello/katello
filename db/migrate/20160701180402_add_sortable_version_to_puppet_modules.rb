class AddSortableVersionToPuppetModules < ActiveRecord::Migration
  class PuppetModule < ActiveRecord::Base
    self.table_name = "katello_puppet_modules"
  end

  # copied from Util::Package
  def sortable_version(version)
    return "" if version.blank?
    pieces = version.scan(/([A-Za-z]+|\d+)/).flatten.map do |chunk|
      chunk =~ /\d+/ ? "#{"%02d" % chunk.length}-#{chunk}" : "$#{chunk}"
    end
    pieces.join(".")
  end

  def up
    add_column :katello_puppet_modules, :sortable_version, :string

    Katello::PuppetModule.find_each do |puppet_mod|
      puppet_mod.update_attribute(:sortable_version, sortable_version(puppet_mod.version))
    end
  end

  def down
    remove_column :katello_puppet_modules, :sortable_version
  end
end
