require 'katello_test_helper'
require Katello::Engine.root.join('db/migrate/20260918090000_use_big_int_for_host_installed_packages_id')

module Katello
  class UseBigIntForHostInstalledPackagesIdTest < ActiveSupport::TestCase
    def setup
      @connection = ActiveRecord::Base.connection
      @migration = UseBigIntForHostInstalledPackagesId.new
      @sequence = @connection.default_sequence_name(:katello_host_installed_packages)
      @host = hosts(:one)
      @package = SimplePackage.new(name: 'bigint-test', version: '1', release: '1', arch: 'noarch', persistence: 'persistent')

      # Recreate the legacy types within the fixture transaction. RESTART is
      # transactional (unlike setval), so boundary tests do not exhaust the shared
      # test sequence after the fixture transaction rolls back.
      @connection.execute("ALTER SEQUENCE #{@sequence} RESTART WITH 1")
      @connection.change_column :katello_host_installed_packages, :id, :integer
      @connection.execute("ALTER SEQUENCE #{@sequence} AS integer")
      HostInstalledPackage.reset_column_information
    end

    def teardown
      HostInstalledPackage.reset_column_information
    end

    def test_upgrade_preserves_associations_and_imports_above_integer_limit
      @host.import_package_profile([@package])
      original = @host.host_installed_packages.first.attributes
      constraints = table_constraints
      indexes = table_indexes

      migrate_up

      assert_equal original, @host.host_installed_packages.first.attributes
      assert_equal constraints, table_constraints
      assert_equal indexes, table_indexes
      assert_bigint_schema
      restart_above_integer_limit

      new_package = SimplePackage.new(name: 'bigint-test-new', version: '1', release: '1', arch: 'noarch')
      @host.import_package_profile([@package, new_package])
      assert_equal 2, @host.host_installed_packages.count
      assert_operator @host.host_installed_packages.maximum(:id), :>, 2**31 - 1
      assert_equal original, HostInstalledPackage.find(original['id']).attributes

      @package.persistence = 'transient'
      @host.import_package_profile([@package])
      assert_equal 1, @host.host_installed_packages.count
      assert_equal 'transient', HostInstalledPackage.find(original['id']).persistence
    end

    def test_upgrade_when_only_column_was_widened
      @connection.change_column :katello_host_installed_packages, :id, :bigint

      migrate_up

      assert_bigint_schema
      assert_import_above_integer_limit
    end

    def test_upgrade_when_only_sequence_was_widened
      @connection.execute("ALTER SEQUENCE #{@sequence} AS bigint")
      restart_above_integer_limit

      migrate_up

      assert_bigint_schema
      assert_import_above_integer_limit
    end

    def test_upgrade_after_workaround_preserves_large_ids_and_sequence_position
      @connection.change_column :katello_host_installed_packages, :id, :bigint
      @connection.execute("ALTER SEQUENCE #{@sequence} AS bigint")
      HostInstalledPackage.reset_column_information
      assert_import_above_integer_limit
      original = @host.host_installed_packages.first.attributes
      sequence_state = @connection.select_one("SELECT last_value, is_called FROM #{@sequence}")

      migrate_up

      assert_bigint_schema
      assert_equal original, @host.host_installed_packages.first.attributes
      assert_equal sequence_state, @connection.select_one("SELECT last_value, is_called FROM #{@sequence}")
      @host.import_package_profile([@package])
      assert_equal original, @host.host_installed_packages.first.attributes
    end

    def test_down_does_not_narrow_ids
      migrate_up
      assert_import_above_integer_limit

      assert_raises(ActiveRecord::IrreversibleMigration) { @migration.down }

      assert_bigint_schema
      assert_operator @host.host_installed_packages.first.id, :>, 2**31 - 1
    end

    private

    def migrate_up
      @migration.up
      HostInstalledPackage.reset_column_information
    end

    def restart_above_integer_limit
      @connection.execute("ALTER SEQUENCE #{@sequence} RESTART WITH 2147483648")
    end

    def assert_import_above_integer_limit
      restart_above_integer_limit
      @host.import_package_profile([@package])
      assert_operator @host.host_installed_packages.first.id, :>, 2**31 - 1
    end

    def assert_bigint_schema
      assert_equal 'bigint', HostInstalledPackage.columns_hash['id'].sql_type
      sequence_type, maximum = @connection.select_rows(<<~SQL).first
        SELECT seqtypid::regtype::text, seqmax FROM pg_sequence
        WHERE seqrelid = #{@connection.quote(@sequence)}::regclass
      SQL
      assert_equal 'bigint', sequence_type
      assert_equal 2**63 - 1, maximum
    end

    def table_constraints
      @connection.select_rows(<<~SQL)
        SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint
        WHERE conrelid = 'katello_host_installed_packages'::regclass
        ORDER BY conname
      SQL
    end

    def table_indexes
      @connection.indexes(:katello_host_installed_packages).map { |index| [index.name, index.columns, index.unique] }
    end
  end
end
