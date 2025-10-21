class AddDebFieldsToAcs < ActiveRecord::Migration[7.0]
  def change
    add_column :katello_alternate_content_sources, :deb_releases, :string
    add_column :katello_alternate_content_sources, :deb_components, :string
    add_column :katello_alternate_content_sources, :deb_architectures, :string
  end
end
