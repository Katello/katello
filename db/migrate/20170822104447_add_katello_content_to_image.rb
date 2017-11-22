class AddKatelloContentToImage < ActiveRecord::Migration[4.2]
  def change
    add_column :docker_container_wizard_states_images, :katello_content, :text
  end
end
