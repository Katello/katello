class AddRpmNvra < ActiveRecord::Migration[4.2]
  def up
    add_column :katello_rpms, :nvra, :string, :limit => 1020
    Katello::Rpm.find_each { |r| r.update!(:nvra => r.build_nvra) }
  end

  def down
    remove_column :katello_rpms, :nvra
  end
end
