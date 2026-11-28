require 'katello_test_helper'
require Katello::Engine.root.join('db/migrate/20261103000000_add_repository_unit_indexes')

module Katello
  class AddRepositoryUnitIndexesTest < ActiveSupport::TestCase
    # The migration builds its indexes CONCURRENTLY, which Postgres refuses to run
    # inside a transaction, and preloaded fixtures require one.
    self.use_transactional_tests = false
    self.pre_loaded_fixtures = false

    TABLES = AddRepositoryUnitIndexes::TABLES

    def setup
      @connection = ActiveRecord::Base.connection
      @migration = AddRepositoryUnitIndexes.new
      @migration.down
    end

    def teardown
      @migration.down
      @migration.up
    end

    def test_up_adds_a_repository_index_to_each_table
      @migration.up

      TABLES.each do |table, unit_column|
        assert_equal ['repository_id', unit_column.to_s], index_columns(table)
        assert valid_index?(table), "#{index_name(table)} is not valid"
      end
    end

    def test_up_leaves_an_existing_valid_index_in_place
      @migration.up
      oid = index_oid(:katello_repository_debs)

      @migration.up

      assert_equal oid, index_oid(:katello_repository_debs)
    end

    def test_down_removes_every_index
      @migration.up
      @migration.down

      TABLES.each_key { |table| assert_nil index_oid(table) }
    end

    private

    def index_name(table)
      "idx_#{table}_repository"
    end

    def index_oid(table)
      @connection.select_value("SELECT to_regclass(#{@connection.quote(index_name(table))})::oid")
    end

    def valid_index?(table)
      valid = @connection.select_value("SELECT indisvalid FROM pg_index WHERE indexrelid = to_regclass(#{@connection.quote(index_name(table))})")
      [true, 't'].include?(valid)
    end

    def index_columns(table)
      @connection.select_values(<<~SQL)
        SELECT a.attname
        FROM pg_index i
        JOIN unnest(i.indkey) WITH ORDINALITY AS keys(attnum, position) ON true
        JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = keys.attnum
        WHERE i.indexrelid = to_regclass(#{@connection.quote(index_name(table))})
        ORDER BY keys.position
      SQL
    end
  end
end
