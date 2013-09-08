class CreateNodeEnvironments < ActiveRecord::Migration
  def up
    create_table :nodes_environments do |t|
      t.references :node
      t.references :environment
    end

   add_index "nodes_environments", %w(node_id environment_id), :unique => true
   add_foreign_key :nodes_environments, :nodes, {:name => 'nodes_environments_node_id_fk'}
   add_foreign_key :nodes_environments, :environments, {:name => 'nodes_environments_environment_id_fk'}
  end

  def down
    drop_table :nodes_environments
  end
end
