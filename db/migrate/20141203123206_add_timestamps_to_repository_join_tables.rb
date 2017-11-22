class AddTimestampsToRepositoryJoinTables < ActiveRecord::Migration[4.2]
  def change
    change_table(:katello_repository_errata) do |t|
      t.timestamps
    end

    change_table(:katello_repository_docker_images) do |t|
      t.timestamps
    end
  end
end
