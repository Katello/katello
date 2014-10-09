class AddErrata < ActiveRecord::Migration
  # rubocop:disable MethodLength
  def up
    create_table "katello_errata" do |t|
      t.string "uuid", :null => false
      t.string "errata_id"
      t.timestamps
      t.datetime 'issued'
      t.datetime 'updated'
      t.string 'errata_type'
      t.string 'severity'
      t.string 'title'
      t.text 'solution'
      t.text 'description'
      t.text 'summary'
      t.boolean 'reboot_suggested'
    end

    add_index :katello_errata, :uuid, :unique => true

    create_table "katello_erratum_packages" do |t|
      t.references :erratum, :null => false
      t.string :nvrea, :null => false
      t.string :name, :null => false
      t.string :filename
    end

    add_index :katello_erratum_packages, [:erratum_id, :nvrea, :name, :filename], :unique => true,
                                                                                  :name =>  'katello_erratum_packages_eid_nvrea_n_f'
    add_foreign_key "katello_erratum_packages", "katello_errata",
                    :name => "katello_erratum_packages_errata_id_fk", :column => "erratum_id"

    create_table "katello_erratum_cves" do |t|
      t.references :erratum, :null => false
      t.string :cve_id, :null => false
      t.string :href, :null => true
    end

    add_index :katello_erratum_cves, [:erratum_id, :cve_id, :href], :unique => true
    add_foreign_key "katello_erratum_cves", "katello_errata",
                    :name => "katello_erratum_cves_errata_id_fk", :column => "erratum_id"

    create_table "katello_erratum_bugzillas" do |t|
      t.references :erratum, :null => false
      t.string :bug_id, :null => false
      t.string :href, :null => true
    end

    add_index :katello_erratum_bugzillas, [:erratum_id, :bug_id, :href], :unique => true, :name => 'katello_erratum_bz_eid_bid_href'
    add_foreign_key "katello_erratum_bugzillas", "katello_errata",
                    :name => "katello_erratum_bugzillas_errata_id_fk", :column => "erratum_id"

    create_table "katello_repository_errata" do |t|
      t.references :erratum, :null => false
      t.references :repository, :null => true
    end

    add_index :katello_repository_errata, [:erratum_id, :repository_id], :unique => true

    add_foreign_key "katello_repository_errata", "katello_errata",
                    :name => "katello_repository_errata_errata_id_fk", :column => "erratum_id"
    add_foreign_key "katello_repository_errata", "katello_repositories",
                    :name => "katello_repository_errata_repo_id_fk", :column => "repository_id"

    create_table "katello_system_errata" do |t|
      t.references :erratum, :null => false
      t.references :system, :null => false
    end

    add_index :katello_system_errata, [:erratum_id, :system_id], :unique => true,
                                                                 :name => :katello_system_errata_eid_sid

    add_foreign_key "katello_system_errata", "katello_errata",
                    :name => "katello_system_errata_errata_id", :column => "erratum_id"
    add_foreign_key "katello_system_errata", "katello_systems",
                    :name => "katello_system_errata_system_id", :column => "system_id"
  end

  def down
    drop_table "katello_system_errata"
    drop_table "katello_repository_errata"
    drop_table "katello_erratum_bugzillas"
    drop_table "katello_erratum_cves"
    drop_table "katello_erratum_packages"
    drop_table "katello_errata"
  end
end
