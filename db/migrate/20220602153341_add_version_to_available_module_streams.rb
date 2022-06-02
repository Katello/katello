class AddVersionToAvailableModuleStreams < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_available_module_streams, :version, :string
    remove_index :katello_available_module_streams, name: 'katello_available_module_streams_name_stream_context'
    add_index :katello_available_module_streams, [:name, :stream, :context, :version], :unique => false, :name => :katello_available_module_streams_name_stream
  end
end
