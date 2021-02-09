class AddAvailableModuleStreamContext < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_available_module_streams, :context, :string, :null => true, :default => nil

    remove_index :katello_available_module_streams, name: :katello_available_module_streams_name_stream
    add_index :katello_available_module_streams, [:name, :stream, :context], :unique => true, :name => :katello_available_module_streams_name_stream_context
  end
end
