class MoveContentViewDefinitionsToContentViewDefinitionBases < ActiveRecord::Migration
  def self.up
    remove_index :content_view_definitions, [:organization_id, :label]
    rename_table :content_view_definitions, :content_view_definition_bases
    add_column :content_view_definition_bases, :type, :string
    add_column :content_view_definition_bases, :source_id, :int
    add_column :content_view_versions, :definition_archive_id, :int
  end

  def self.down
    remove_column :content_view_definition_bases, :source_id
    remove_column :content_view_definition_bases, :type
    rename_table :content_view_definition_bases, :content_view_definitions
    remove_column :content_view_versions, :definition_archive_id
    add_index :content_view_definitions, [:organization_id, :label], :unique => true
  end
end
