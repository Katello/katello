class AddDescriptionToKatelloModuleStreams < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_module_streams, :description, :text
    add_column :katello_module_streams, :summary, :text
  end
end
