class AddLabelsToOrg < ActiveRecord::Migration
  def self.up
    change_table(:organizations) do |t|
      t.column :label, :string, :bulk => true
      Organization.all.each do |org|
        execute "update organizations set label = '#{org.cp_key}' where id= #{org.id}"
      end
    end
  end

  def self.down
    change_table(:organizations) { |t| t.remove :label}
  end

end
