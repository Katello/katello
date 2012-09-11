class AddLabelsToProduct < ActiveRecord::Migration
  def self.up
    change_table(:products) do |t|
      t.column :label, :string, :bulk => true
      Product.all.each do |prod|
        execute "update products set label = '#{prod.name}' where id= #{prod.id}"
      end
    end
  end

  def self.down
    change_table(:products) { |t| t.remove :label}
  end
end
