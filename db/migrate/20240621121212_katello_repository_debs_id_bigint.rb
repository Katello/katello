class KatelloRepositoryDebsIdBigint < ActiveRecord::Migration[6.1]
  def change
    change_column :katello_repository_debs, :id, :bigint
    execute 'ALTER SEQUENCE katello_repository_debs_id_seq AS bigint;'
  end
end
