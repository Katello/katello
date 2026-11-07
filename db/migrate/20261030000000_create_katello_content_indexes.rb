class CreateKatelloContentIndexes < ActiveRecord::Migration[7.0]
  INTERNED_TYPES = {
    :rpm => :katello_rpms,
    :erratum => :katello_errata,
    :srpm => :katello_srpms,
    :module_stream => :katello_module_streams,
    :deb => :katello_debs,
    :file_unit => :katello_files,
    :package_group => :katello_package_groups,
    :ansible_collection => :katello_ansible_collections,
    :generic_content_unit => :katello_generic_content_units,
  }.freeze

  def up
    create_table :katello_content_indices do |t|
      t.string :version_href, :null => false, :limit => 255
      t.timestamps
    end
    add_index :katello_content_indices, :version_href, :unique => true

    INTERNED_TYPES.each do |unit, unit_table|
      create_association_table(unit, unit_table)
    end

    add_column :katello_repositories, :content_index_id, :bigint
    add_index :katello_repositories, :content_index_id
    add_foreign_key :katello_repositories, :katello_content_indices, :column => :content_index_id
  end

  def down
    remove_foreign_key :katello_repositories, :column => :content_index_id
    remove_index :katello_repositories, :content_index_id
    remove_column :katello_repositories, :content_index_id

    INTERNED_TYPES.each_key do |unit|
      drop_table association_table(unit)
    end

    drop_table :katello_content_indices
  end

  private

  # Mirrors the per-repository join table, keyed by content index.
  def create_association_table(unit, unit_table)
    create_table association_table(unit) do |t|
      t.bigint :content_index_id, :null => false
      t.bigint :"#{unit}_id", :null => false

      if unit == :erratum
        t.string :erratum_pulp3_href
        t.string :erratum_prn
      end

      t.timestamps
    end
    add_index association_table(unit), [:"#{unit}_id", :content_index_id], :unique => true,
              :name => "idx_#{association_table(unit)}_unit"
    # Ordered for "units of these content sets", answered index-only.
    add_index association_table(unit), [:content_index_id, :"#{unit}_id"], :name => "idx_#{association_table(unit)}_ci"
    add_foreign_key association_table(unit), :katello_content_indices, :column => :content_index_id
    add_foreign_key association_table(unit), unit_table, :column => :"#{unit}_id"
  end

  def association_table(unit)
    :"katello_content_index_#{unit.to_s.pluralize}"
  end
end
