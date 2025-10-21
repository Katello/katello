class AddDebFieldsToAcs < ActiveRecord::Migration[7.0]
  def change
    add_column :katello_alternate_content_sources, :distributions, :text, array: true, default: []
    add_column :katello_alternate_content_sources, :components, :text, array: true, default: []
    add_column :katello_alternate_content_sources, :architectures, :text, array: true, default: []
    add_index :katello_alternate_content_sources, :distributions
  end
end
