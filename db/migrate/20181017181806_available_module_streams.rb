class AvailableModuleStreams < ActiveRecord::Migration[5.2]
  def up
    create_table :katello_available_module_streams do |t|
      t.string :name
      t.string :stream
    end

    create_table :katello_host_available_module_streams do |t|
      t.references :host, :null => false, :index => true
      t.references :available_module_stream, :null => false, :index => false
      t.text :installed_profiles
      t.string :status
    end

    add_index :katello_available_module_streams, [:name, :stream], :unique => true, :name => :katello_available_module_streams_name_stream

    add_foreign_key :katello_host_available_module_streams, :hosts,
                    :name => :katello_hems_host_id_fk, :column => :host_id

    add_foreign_key :katello_host_available_module_streams, :katello_available_module_streams,
                    :name => :katello_hems_available_module_stream_id_fk, :column => :available_module_stream_id

    add_index :katello_host_available_module_streams, :available_module_stream_id,
              name: :index_katello_hems_available_module_stream_id
  end

  def down
    remove_foreign_key :katello_host_available_module_streams, name: :katello_hems_host_id_fk
    remove_foreign_key :katello_host_available_module_streams, name: :katello_hems_available_module_stream_id_fk

    drop_table :katello_host_available_module_streams
    drop_table :katello_available_module_streams
  end
end
