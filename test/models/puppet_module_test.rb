require 'katello_test_helper'

module Katello
  class PuppetModuleTest < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:p_forge)
      @dhcp = katello_puppet_modules(:dhcp)
      @abrt = katello_puppet_modules(:abrt)
      PuppetModule.any_instance.stubs(:backend_data).returns({})
    end

    def test_create
      pulp_id = 'foo'
      create(:puppet_module, :pulp_id => pulp_id)
      assert PuppetModule.find_by_pulp_id(pulp_id)
    end

    def test_sortable_version
      version = '1.20.4'
      puppet_module = create(:puppet_module, :version => version)
      assert_equal Util::Package.sortable_version(version), puppet_module.sortable_version
    end

    def test_with_identifiers
      assert_includes PuppetModule.with_identifiers(@abrt.id), @abrt
      assert_includes PuppetModule.with_identifiers([@abrt.id]), @abrt
      assert_includes PuppetModule.with_identifiers(@abrt.pulp_id), @abrt
    end

    def test_group_by_repoid
      puppet_modules = PuppetModule.group_by_repoid([@abrt, @dhcp])
      assert_equal puppet_modules.keys.length, 1
      assert_equal puppet_modules[@repo.id].sort, [@abrt, @dhcp].sort
    end

    def test_parse_metadata
      filepath = File.join(Katello::Engine.root, "test/fixtures/puppet/puppetlabs-ntp-2.0.1.tar.gz")
      metadata = PuppetModule.parse_metadata(filepath)

      assert_equal "Puppet Labs", metadata[:author]
      assert_equal "puppetlabs-ntp", metadata[:name]
      assert_equal "2.0.1", metadata[:version]
      assert_equal "NTP Module", metadata[:summary]
    end

    def test_parse_metadata_with_bad_file
      filepath = __FILE__
      assert_raises(Katello::Errors::InvalidPuppetModuleError) do
        PuppetModule.parse_metadata(filepath)
      end
    end

    def test_latest_module
      puppet_module1 = create(:puppet_module, :version => "1.12.0")
      puppet_module2 = create(:puppet_module, :version => "1.3.0")
      @repo.puppet_modules = [puppet_module1, puppet_module2]

      pmodule = PuppetModule.latest_module("trystero",
                                           "tpynchon",
                                           @repo
                                          )

      # should be 1.12.0 and not 1.3.0
      assert_equal "1.12.0", pmodule.version
      assert_equal puppet_module1.id, pmodule.id
    end
  end
end
