class AddAutoEnabledToRootRepository < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_root_repositories, :auto_enabled, :boolean, default: true
  end
end
