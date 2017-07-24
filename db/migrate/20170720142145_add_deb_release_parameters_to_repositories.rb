class AddDebReleaseParametersToRepositories < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_repositories, :deb_releases, :string, limit: 255
    add_column :katello_repositories, :deb_components, :string, limit: 255
    add_column :katello_repositories, :deb_architectures, :string, limit: 255
  end
end
