class AddContentIdToKatelloRepository < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_repositories, :content_id, :string
  end
end
