class AddTrigramIndexesForErrataSearch < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

    add_index :katello_errata, :title,
              using: :gin, opclass: :gin_trgm_ops,
              name: 'index_katello_errata_on_title_trgm',
              algorithm: :concurrently
    add_index :katello_erratum_cves, :cve_id,
              using: :gin, opclass: :gin_trgm_ops,
              name: 'index_katello_erratum_cves_on_cve_id_trgm',
              algorithm: :concurrently
    add_index :katello_erratum_bugzillas, :bug_id,
              using: :gin, opclass: :gin_trgm_ops,
              name: 'index_katello_erratum_bugzillas_on_bug_id_trgm',
              algorithm: :concurrently
  end

  def down
    remove_index :katello_errata, name: 'index_katello_errata_on_title_trgm', algorithm: :concurrently
    remove_index :katello_erratum_cves, name: 'index_katello_erratum_cves_on_cve_id_trgm', algorithm: :concurrently
    remove_index :katello_erratum_bugzillas, name: 'index_katello_erratum_bugzillas_on_bug_id_trgm', algorithm: :concurrently
  end
end
