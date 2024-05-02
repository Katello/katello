class ChangeKatelloRepositoryRpmsIdSeqToBigInt < ActiveRecord::Migration[6.1]
  def up
    execute 'ALTER SEQUENCE katello_repository_rpms_id_seq AS bigint;'
  end

  def down
    execute 'ALTER SEQUENCE katello_repository_rpms_id_seq AS integer;'
  end
end
