class AddOriginalModulesToContentViewModuleStreamFilter < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_content_view_filters, :original_module_streams, :boolean, :default => false, :null => false
  end
end
