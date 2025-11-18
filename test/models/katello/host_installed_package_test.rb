require 'katello_test_helper'

module Katello
  class HostInstalledPackageTest < ActiveSupport::TestCase
    def setup
      @host = hosts(:one)
      @installed_packages = []
      Katello::HostInstalledPackage::PERSISTENCE_VALUES.length.times do |i|
        @installed_packages << Katello::InstalledPackage.create!(
          name: "test-package-#{i}",
          nvra: "test-package-#{i}-1.0-1.el9.x86_64",
          version: '1.0',
          release: '1',
          nvrea: "test-package-#{i}-1.0-1.el9.x86_64",
          arch: 'x86_64'
        )
      end
    end

    test "can create host installed package with unknown persistence" do
      hip = Katello::HostInstalledPackage.create(
        host: @host,
        installed_package: @installed_packages[0],
        persistence: nil
      )
      assert hip.persisted?, "Record with nil persistence was not saved. Verify HostInstalledPackage CHECK constraint allows this value."
      assert hip.valid?, "Expected nil persistence to be valid"
      assert_nil hip.persistence
    end

    test 'can create host installed package with all persistence values' do
      Katello::HostInstalledPackage::PERSISTENCE_VALUES.each_with_index do |value, i|
        hip = Katello::HostInstalledPackage.create(
          host: @host,
          installed_package: @installed_packages[i],
          persistence: value
        )
        assert hip.persisted?, "Record with persistence value '#{value}' was not saved. Verify HostInstalledPackage CHECK constraint allows this value."
        assert hip.valid?, "Expected persistence value '#{value}' to be valid"
        assert_equal value, hip.persistence
      end
    end

    # tests model validation (usually bypassed)
    test "validates persistence is in allowed values" do
      hip = Katello::HostInstalledPackage.new(
        host: @host,
        installed_package: @installed_packages[0],
        persistence: 'invalid_value'
      )
      refute hip.valid?
      assert_includes hip.errors[:persistence], "is not included in the list"
    end

    # tests database check constraint
    test "database check constraint rejects invalid persistence values" do
      hip = Katello::HostInstalledPackage.new(
        host: @host,
        installed_package: @installed_packages[0],
        persistence: 'invalid_value'
      )

      error = assert_raises(ActiveRecord::StatementInvalid) do
        hip.save(validate: false)
      end

      assert_match(/check_persistence_values/, error.message)
      assert_match(/violates check constraint/, error.message)
    end

    test "PERSISTENCE_VALUES constant contains expected values" do
      assert_equal %w[transient persistent], Katello::HostInstalledPackage::PERSISTENCE_VALUES
    end
  end
end
