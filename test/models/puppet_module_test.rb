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
      uuid = 'foo'
      assert PuppetModule.create!(:uuid => uuid, :author => 'katello', :name => 'pulp')
      assert PuppetModule.find_by_uuid(uuid)
    end

    def test_update_from_json
      uuid = 'foo'
      assert PuppetModule.create!(:uuid => uuid, :author => 'katello', :name => 'pulp')
      json = @dhcp.attributes.merge('summary' => 'an update', 'version' => '3', 'name' => 'dns', 'author' => 'katello')
      @dhcp.update_from_json(json.with_indifferent_access)
      @dhcp = PuppetModule.find(@dhcp)

      assert_equal @dhcp.summary, json['summary']
      assert_equal @dhcp.name, json['name']
      assert_equal @dhcp.author, json['author']
    end

    def test_update_from_json_is_idempotent
      last_updated = @abrt.updated_at
      json = @abrt.attributes
      @abrt.update_from_json(json)
      assert_equal PuppetModule.find(@abrt).updated_at, last_updated
    end

    def test_with_identifiers
      assert_includes PuppetModule.with_identifiers(@abrt.id), @abrt
      assert_includes PuppetModule.with_identifiers([@abrt.id]), @abrt
      assert_includes PuppetModule.with_identifiers(@abrt.uuid), @abrt
    end

    def test_group_by_repoid
      puppet_modules = PuppetModule.group_by_repoid([@abrt, @dhcp])
      assert_equal puppet_modules.keys.length, 1
      assert_equal puppet_modules[@repo.pulp_id].sort, [@abrt.uuid, @dhcp.uuid].sort
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
  end
end
