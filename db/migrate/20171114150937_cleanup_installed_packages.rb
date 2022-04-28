class CleanupInstalledPackages < ActiveRecord::Migration[4.2]
  def up
    create_table "katello_installed_packages_new", force: :cascade do |t|
      t.string "name", limit: 255, null: false
      t.string "nvra", limit: 255, null: false
    end

    create_table "katello_host_installed_packages_new", force: :cascade do |t|
      t.integer "host_id",              null: false
      t.integer "installed_package_id", null: false
    end

    #Copy unique entires to new table
    execute('insert into katello_installed_packages_new(nvra, name)
       select distinct(nvra) as nvra, name from katello_installed_packages')

    #copy associations
    execute('
    insert into katello_host_installed_packages_new (host_id, installed_package_id)
      select distinct katello_host_installed_packages.host_id, katello_installed_packages_new.id
        from katello_installed_packages
        inner join katello_host_installed_packages on  katello_host_installed_packages.installed_package_id = katello_installed_packages.id
        inner join  katello_installed_packages_new on katello_installed_packages_new.nvra = katello_installed_packages.nvra')

    remove_foreign_key :katello_host_installed_packages, name: "katello_host_installed_packages_installed_package_id"
    remove_foreign_key :katello_host_installed_packages, name: "katello_host_installed_packages_host_id"

    drop_table "katello_installed_packages"
    drop_table "katello_host_installed_packages"

    rename_table "katello_installed_packages_new", "katello_installed_packages"
    rename_table "katello_host_installed_packages_new", "katello_host_installed_packages"

    add_index :katello_installed_packages, [:name, :nvra]

    add_foreign_key "katello_host_installed_packages", "hosts",
                    :name => "katello_host_installed_packages_host_id", :column => "host_id"

    add_foreign_key "katello_host_installed_packages", "katello_installed_packages",
                    :name => "katello_host_installed_packages_installed_package_id", :column => "installed_package_id"

    #At this point, everything should be back to where it was (sans-duplicates)
    # Now do new things
    add_index :katello_installed_packages, [:nvra], :unique => true
    add_index :katello_host_installed_packages, [:host_id, :installed_package_id], :unique => true, :name => :katello_host_installed_packages_h_id_ip_id
    Setting.where(:name => 'bulk_query_installed_packages').delete_all
  end

  def down
    #only revert new things
    remove_index :katello_installed_packages, [:nvra]
    remove_index :katello_host_installed_packages, :name => :katello_host_installed_packages_h_id_ip_id
    #Setting will be recreated on startup
  end
end
