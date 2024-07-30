class AddPriorityToContentViewEnvironmentActivationKey < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_content_view_environment_activation_keys, :priority, :integer, default: 0, null: false
  end
end
