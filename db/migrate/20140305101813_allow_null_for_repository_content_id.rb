class AllowNullForRepositoryContentId < ActiveRecord::Migration
  def change
    change_column :katello_repositories, :content_id, :string, null: true,
      :limit => 255
  end
end
