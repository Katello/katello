class AddInstalledDeb < ActiveRecord::Migration[4.2]
  def change
    create_table "katello_installed_debs" do |t|
      t.string 'name', :null => false, :limit => 255
      t.string 'version', :null => false, :limit => 255
      t.string 'architecture', :null => false, :limit => 255
    end

    create_table "katello_host_installed_debs" do |t|
      t.references 'host', :null => false, :index => true
      t.references 'installed_deb', :null => false, :index => true
    end

    add_foreign_key "katello_host_installed_debs", "hosts",
                    :name => "katello_host_installed_debs_host_id", :column => "host_id"

    add_foreign_key "katello_host_installed_debs", "katello_installed_debs",
                    :name => "katello_host_installed_debs_installed_deb_id", :column => "installed_deb_id"

    add_index :katello_installed_debs, [:name, :version, :architecture], :unique => true, :name => :katello_installed_debs_n_id_v_id_a_id
    add_index :katello_host_installed_debs, [:host_id, :installed_deb_id], :unique => true, :name => :katello_host_installed_debs_h_id_ip_id
  end
end
