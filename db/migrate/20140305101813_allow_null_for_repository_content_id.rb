class AllowNullForRepositoryContentId < ActiveRecord::Migration[4.2]
  def change
    change_column :katello_repositories, :content_id, :string, null: true,
      :limit => 255
  end
end
