class AddTimestampsToRepositoryJoinTables < ActiveRecord::Migration[4.2]
  def change
    change_table(:katello_repository_errata) do |t|
      t.timestamps
    end
  end
end
