class UseBigIntForErratumPackagesId < ActiveRecord::Migration[7.0]
  def up
    execute 'ALTER SEQUENCE katello_erratum_packages_id_seq AS bigint;'
    change_column :katello_erratum_packages, :id, :bigint
  end

  def down
    change_column :katello_erratum_packages, :id, :integer
    execute 'ALTER SEQUENCE katello_erratum_packages_id_seq AS integer;'
  end
end
