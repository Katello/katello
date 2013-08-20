class Node < ActiveRecord::Migration
  def up
    create_table :nodes do |t|
      t.references :system
      t.timestamps
    end

    add_index "nodes", ["system_id"], :unique=>true
    add_foreign_key :nodes, :systems, {:name=>'nodes_system_id_fk'}
  end

  def down
    drop_table :nodes
  end
end
