class ChangeRepositoryPasswordToText < ActiveRecord::Migration[5.2]
  def up
    change_column :katello_repositories, :upstream_password, :text
  end

  def down
    add_column :katello_repositories, :temp_upstream_password, :string, :limit => 1024

    Katello::Repository.find_each do |repo|
      next if repo.upstream_password.blank?
      repo.update_column(:temp_upstream_password, repo.upstream_password.length > 1024 ? nil : repo.upstream_password)
    end

    remove_column :katello_repositories, :upstream_password
    rename_column :katello_repositories, :temp_upstream_password, :upstream_password
  end
end
