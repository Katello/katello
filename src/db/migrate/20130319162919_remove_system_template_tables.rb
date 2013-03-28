class RemoveSystemTemplateTables < ActiveRecord::Migration

  def self.safe_drop_table(table)
    if ActiveRecord::Base.connection.tables.include?(table.to_s)
      drop_table table
    else
      say "Table #{table} does not exist. Skipping."
    end
  end

  def self.safe_remove_column(table, column)
    klass = table.to_s.singularize.camelize.constantize
    if klass.column_names.include?(column.to_s)
      remove_column table, column
    else
      say "Table #{table} does not have #{column}. Skipping."
    end
  end

  def self.up
    [:products_system_templates,
     :system_templates,
     :changesets_system_templates,
     :system_template_pack_groups,
     :system_template_pg_categories,
     :system_template_packages,
     :system_template_distributions,
     :system_template_repositories
    ].each { |t| safe_drop_table(t) }

    safe_remove_column :systems, :system_template_id
    safe_remove_column :activation_keys, :system_template_id
  end

  def self.down
    # permanent action, cannot be undone
  end
end
