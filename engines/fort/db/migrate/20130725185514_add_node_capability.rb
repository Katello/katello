class AddNodeCapability < ActiveRecord::Migration
  def up
   create_table :node_capabilities do |t|
     t.references :node
     t.text :configuration
     t.string :type
   end

   add_index "node_capabilities", ["node_id", "type"], :unique=>true
   add_foreign_key :node_capabilities, :nodes, {:name=>'node_capabilities_node_id_fk'}
  end

  def down
    drop_table :node_capabilities
  end
end
