class AddLabelsToOrg < ActiveRecord::Migration
  def self.up
    change_table(:organizations) do |t|
      t.column :label, :string, :bulk => true
      Organization.all.each do |org|
        execute "update organizations set label = '#{org.cp_key}' where id= #{org.id}"
      end
    end
    add_index(:organizations, [:label], :unique => true)
  end

  def self.down
    remove_index(:organizations, :column => [:label])
    change_table(:organizations) { |t| t.remove :label}
  end

end
