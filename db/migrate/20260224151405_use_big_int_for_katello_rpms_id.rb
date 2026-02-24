class UseBigIntForKatelloRpmsId < ActiveRecord::Migration[7.0]
  def up
    execute 'ALTER SEQUENCE katello_rpms_id_seq AS bigint;'
    change_column :katello_rpms, :id, :bigint

    remove_foreign_key :katello_repository_rpms, column: :rpm_id
    change_column :katello_repository_rpms, :rpm_id, :bigint
    add_foreign_key :katello_repository_rpms, :katello_rpms, column: :rpm_id
  end

  def down
    remove_foreign_key :katello_repository_rpms, column: :rpm_id
    change_column :katello_repository_rpms, :rpm_id, :integer
    add_foreign_key :katello_repository_rpms, :katello_rpms, column: :rpm_id

    change_column :katello_rpms, :id, :integer
    execute 'ALTER SEQUENCE katello_rpms_id_seq AS integer;'
  end
end
