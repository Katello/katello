class ChangeRepositoryPasswordLength < ActiveRecord::Migration[5.1]
  def change
    change_column :katello_repositories, :upstream_password, :string, limit: 1024
  end
end
