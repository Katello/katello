class AddGenericRemoteOptionsToRootRepository < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_root_repositories, :generic_remote_options, :text
  end
end
