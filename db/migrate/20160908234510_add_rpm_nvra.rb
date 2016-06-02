class AddRpmNvra < ActiveRecord::Migration
  def up
    add_column :katello_rpms, :nvra, :string, :limit => 1020
    Katello::Rpm.find_each { |r| r.update_attributes!(:nvra => r.build_nvra) }
  end

  def down
    remove_column :katello_rpms, :nvra
  end
end
