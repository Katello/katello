class UseBigIntForErratumPackagesId < ActiveRecord::Migration[7.0]
  def up
    cleanup_duplicate_erratum_packages
    execute 'ALTER SEQUENCE katello_erratum_packages_id_seq AS bigint;'
    change_column :katello_erratum_packages, :id, :bigint
  end

  def down
    change_column :katello_erratum_packages, :id, :integer
    execute 'ALTER SEQUENCE katello_erratum_packages_id_seq AS integer;'
  end

  def cleanup_duplicate_erratum_packages
    duplicate_groups = Katello::ErratumPackage
                        .select(:nvrea, :erratum_id, :name, :filename)
                        .group(:nvrea, :erratum_id, :name, :filename)
                        .having('COUNT(*) > 1')

    return if duplicate_groups.empty?

    ids_to_delete = []
    update_mappings = {}

    duplicate_groups.each do |group|
      duplicate_ids = Katello::ErratumPackage
                       .where(
                        nvrea: group.nvrea,
                        erratum_id: group.erratum_id,
                        name: group.name,
                        filename: group.filename
                       )
                       .order(:id)
                       .pluck(:id)

      id_to_keep = duplicate_ids.first
      ids_to_remove = duplicate_ids[1..]

      ids_to_delete.concat(ids_to_remove)
      ids_to_remove.each { |id| update_mappings[id] = id_to_keep }
    end

    return if ids_to_delete.empty?

    update_mappings.each_slice(1000) do |batch|
      batch.each do |old_id, new_id|
        Katello::ModuleStreamErratumPackage
         .where(erratum_package_id: old_id)
         .where(
          module_stream_id: Katello::ModuleStreamErratumPackage
                             .where(erratum_package_id: new_id)
                             .select(:module_stream_id)
         )
         .delete_all

        Katello::ModuleStreamErratumPackage
         .where(erratum_package_id: old_id)
         .update_all(erratum_package_id: new_id)
      end
    end
  
    Katello::ErratumPackage.where(id: ids_to_delete).delete_all
  end
end
