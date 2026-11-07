class AddRepositoryUnitIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  # These four association tables only ever got the unit-id-leading unique
  # index, so a repository_id predicate cannot use it; the other unit types
  # already carry the companion index.
  #
  # An interrupted concurrent build leaves an INVALID index behind; if_not_exists
  # would skip it on a retry and the migration would finish without a usable
  # index, so drop it before rebuilding.
  TABLES = {
    :katello_repository_debs => :deb_id,
    :katello_repository_srpms => :srpm_id,
    :katello_repository_file_units => :file_unit_id,
    :katello_repository_generic_content_units => :generic_content_unit_id,
  }.freeze

  def up
    TABLES.each do |table, unit_column|
      remove_index table, :name => index_name(table), :algorithm => :concurrently, :if_exists => true if invalid_index?(table)
      add_index table, [:repository_id, unit_column],
                :name => index_name(table), :algorithm => :concurrently, :if_not_exists => true
    end
  end

  def down
    TABLES.each_key do |table|
      remove_index table, :name => index_name(table), :algorithm => :concurrently, :if_exists => true
    end
  end

  private

  def index_name(table)
    "idx_#{table}_repository"
  end

  def invalid_index?(table)
    valid = connection.select_value(<<~SQL)
      SELECT indisvalid FROM pg_index
      WHERE indexrelid = to_regclass(#{connection.quote(index_name(table))})
    SQL
    [false, 'f'].include?(valid)
  end
end
