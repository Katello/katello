class AddMoreDebFields < ActiveRecord::Migration[6.1]
  def up
    add_column :katello_debs, :section, :string, :limit => 255
    add_column :katello_debs, :maintainer, :string, :limit => 255
    add_column :katello_debs, :homepage, :string, :limit => 255
    add_column :katello_debs, :installed_size, :string, :limit => 255
  end

  def down
    remove_column :katello_debs, :section
    remove_column :katello_debs, :maintainer
    remove_column :katello_debs, :homepage
    remove_column :katello_debs, :installed_size
  end
end
