class KatelloRepositoryRpmsIdBigInt < ActiveRecord::Migration[5.2]
  def change
    change_column :katello_repository_rpms, :id, :bigint
  end
end
