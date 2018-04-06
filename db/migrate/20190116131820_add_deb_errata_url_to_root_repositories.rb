class AddDebErrataUrlToRootRepositories < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_root_repositories, :deb_errata_url, :string, limit: 255
    add_column :katello_root_repositories, :deb_errata_url_etag, :string, limit: 255
  end
end
