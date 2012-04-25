class FilterAddName < ActiveRecord::Migration
  def self.up
    add_column :filters, :name, :string, :null=>true
    Filter.reset_column_information
    User.current = User.hidden.first
    Filter.all.each{|f|  
        f.name = f.pulp_id 
        f.save! 
    }
    change_column :filters, :name, :string, :null => false
  end

  def self.down
    remove_column :filters, :name
  end
end
