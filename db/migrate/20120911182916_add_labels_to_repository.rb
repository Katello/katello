class AddLabelsToRepository < ActiveRecord::Migration
  def self.up
    change_table(:repositories) do |t|
      t.column :label, :string, :bulk => true
      Repository.all.each do |repo|
        execute "update repositories set label = '#{Util::Model.labelize(repo.name)}' where id= #{repo.id}"
      end
      t.change :label, :string, :null => false
    end
    add_index(:repositories, [:label, :environment_product_id], :unique => true)
  end

  def self.down
    remove_index(:repositories, :column => [:label, :environment_product_id])
    change_table(:repositories) { |t| t.remove :label}
  end
end
