class AddContainerPushPropsToRepo < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_root_repositories, :is_container_push, :boolean, default: false
    add_column :katello_root_repositories, :container_push_name, :string, default: nil
    add_column :katello_root_repositories, :container_push_name_format, :string, default: nil
  end
end
