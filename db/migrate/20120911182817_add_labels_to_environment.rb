class AddLabelsToEnvironment < ActiveRecord::Migration
  def self.up
    change_table(:environments) do |t|
      t.column :label, :string, :bulk => true
      KTEnvironment.all.each do |env|
        execute "update environments set label = '#{env.name}' where id= #{env.id}"
      end
    end
  end

  def self.down
    change_table(:environments) { |t| t.remove :label}
  end
end

