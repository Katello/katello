class AddRepositoryContainerVer < ActiveRecord::Migration
  def change
    add_column :katello_repositories, :containerver, :string
  end
end
