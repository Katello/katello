class AddGeneratedForToContentViews < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_content_views, :generated_for, :integer, :default => 0, :null => false
    ::Katello::ContentView.reset_column_information
    ::Katello::ContentView.
      where(label: ::Katello::ContentView::IMPORT_LIBRARY).
      update(generated_for: :library_import)

    ::Katello::ContentView.
      where('label like ?', "#{::Katello::ContentView::EXPORT_LIBRARY}%").
      update(generated_for: :library_export)
  end
end
