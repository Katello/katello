class AddTypeToKatelloRepositories < ActiveRecord::Migration
  def change
    add_column :katello_repositories, :type, :string
  end
end
