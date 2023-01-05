class InstalledPackageBadNvrea < ActiveRecord::Migration[5.2]
  def up
    Katello::InstalledPackage.where(:epoch => "0").find_each do |pkg|
      simple = Katello::SimplePackage.new(pkg.attributes)
      if pkg.nvrea != simple.nvrea
        pkg.update_column(:nvrea, simple.nvrea)
      end
    end
  end

  def down
    #noop
  end
end
