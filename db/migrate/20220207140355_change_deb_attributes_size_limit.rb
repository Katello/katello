class ChangeDebAttributesSizeLimit < ActiveRecord::Migration[6.0]
  def change
    change_column :katello_root_repositories, :deb_releases, :text
    change_column :katello_root_repositories, :deb_components, :text
    change_column :katello_root_repositories, :deb_architectures, :text
  end
end
