class AddLabelsToEnvironment < ActiveRecord::Migration
  def self.up
    change_table(:environments) do |t|
      t.column :label, :string, :bulk => true
      KTEnvironment.all.each do |env|
        execute "update environments set label = '#{env.name}' where id= #{env.id}"
      end
    end
    add_index(:environments, [:label, :organization_id], :unique => true)
  end

  def self.down
    #remove_index(:environments, :column =>[:label, :organization_id])
    change_table(:environments) { |t| t.remove :label}
  end
end

