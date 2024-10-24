require 'katello_test_helper'

module Katello
  class HostCollectionTest < ActiveSupport::TestCase
    def setup
      @organization = get_organization
      @simple_collection = katello_host_collections(:simple_host_collection)
      @limited_collection = katello_host_collections(:limited_hosts_host_collection)
      @host_one = hosts(:one)
      @host_two = hosts(:two)
    end

    def test_search_by_name
      assert_equal HostCollection.search_for("name = \"#{@simple_collection.name}\""), [@simple_collection]
      assert_equal HostCollection.search_for("name = \"unknown collection\""), []
    end

    def test_search_by_host
      assert_equal HostCollection.search_for("host = \"#{@host_one.name}\"").sort, [@simple_collection, @limited_collection].sort
      assert_equal HostCollection.search_for("host = \"#{@host_two.name}\""), []
    end

    test_attributes :pid => '8f2b9223-f5be-4cb1-8316-01ea747cae14'
    def test_create_with_name
      valid_name_list.each do |name|
        host_collection = HostCollection.new(:name => name, :organization => @organization)
        assert host_collection.valid?, "Validation failed for create with valid name: '#{name}' length: #{name.length})"
        assert_equal name, host_collection.name
      end
    end

    test_attributes :pid => '9d13392f-8d9d-4ff1-8909-4233e4691055'
    def test_create_with_description
      valid_name_list.each do |description|
        host_collection = HostCollection.new(:name => 'new_host_collection', :description => description, :organization => @organization)
        assert host_collection.valid?, "Validation failed for create with valid description: '#{description}' length: #{description.length})"
        assert_equal description, host_collection.description
      end
    end

    test_attributes :pid => '86d9387b-7036-4794-96fd-5a3472dd9160'
    def test_create_with_limit
      [1, 3, 5, 10, 20].each do |limit|
        host_collection = HostCollection.new(
          :name => 'new_host_collection',
          :max_hosts => limit,
          :unlimited_hosts => false,
          :organization => @organization
        )
        assert host_collection.valid?, "Validation failed for create with valid max_hosts: '#{limit}'"
        assert_equal limit, host_collection.max_hosts
      end
    end

    test_attributes :pid => 'd385574e-5794-4442-b6cd-e5ded001d877'
    def test_create_with_unlimited_hosts
      [true, false].each do |unlimited_hosts|
        max_hosts = unlimited_hosts ? nil : 1
        host_collection = HostCollection.new(
          :name => 'new_host_collection',
          :unlimited_hosts => unlimited_hosts,
          :max_hosts => max_hosts,
          :organization => @organization
        )
        assert host_collection.valid?, "Validation failed for create with valid unlimited_hosts: '#{unlimited_hosts}'"
        assert_equal unlimited_hosts, host_collection.unlimited_hosts
      end
    end

    test_attributes :pid => 'bb8d2b42-9a8b-4c4f-ba0c-c56ae5a7eb1d'
    def test_create_with_hosts
      hosts = 2.times.map { FactoryBot.create(:host, :organization => @organization) }
      host_collection = HostCollection.new(
        :name => 'new_host_collection',
        :unlimited_hosts => true,
        :organization => @organization,
        :hosts => hosts
      )
      assert_valid host_collection
      assert_equal 2, host_collection.hosts.length
    end

    test_attributes :pid => 'b2dedb99-6dd7-41be-8aaa-74065c820ac6'
    def test_update_name
      valid_name_list.each do |new_name|
        @simple_collection.name = new_name
        assert @simple_collection.valid?, "Validation failed for update with valid name: '#{new_name}' length: #{new_name.length})"
        assert_equal new_name, @simple_collection.name
      end
    end

    test_attributes :pid => 'f8e9bd1c-1525-4b5f-a07c-eb6b6e7aa628'
    def test_update_description
      valid_name_list.each do |new_description|
        @simple_collection.description = new_description
        assert @simple_collection.valid?, "Validation failed for update with valid description: '#{new_description}' length: #{new_description.length})"
        assert_equal new_description, @simple_collection.description
      end
    end

    test_attributes :pid => '4eda7796-cd81-453b-9b72-4ef84b2c1d8c'
    def test_update_limit
      @simple_collection.unlimited_hosts = false
      @simple_collection.max_hosts = 1
      assert @simple_collection.save
      [3, 5, 10, 20].each do |limit|
        @simple_collection.max_hosts = limit
        assert @simple_collection.valid?, "Validation failed for update with valid max_hosts: '#{limit}'"
        assert_equal limit, @simple_collection.max_hosts
      end
    end

    test_attributes :pid => '09a3973d-9832-4255-87bf-f9eaeab4aee8'
    def test_update_unlimited_hosts
      initial_unlimited = @simple_collection.unlimited_hosts
      [!initial_unlimited, initial_unlimited].each do |unlimited_hosts|
        @simple_collection.unlimited_hosts = unlimited_hosts
        @simple_collection.max_hosts = unlimited_hosts ? nil : 1
        assert @simple_collection.valid?, "Validation failed for update with valid unlimited_hosts: '#{unlimited_hosts}'"
        assert_equal unlimited_hosts, @simple_collection.unlimited_hosts
      end
    end

    test_attributes :pid => '23082854-abcf-4085-be9c-a5d155446acb'
    def test_positive_update_host
      @simple_collection.hosts = [@host_two]
      assert_valid @simple_collection
      assert_equal 1, @simple_collection.hosts.length
      assert_equal @host_two.id, @simple_collection.hosts[0].id
    end

    test_attributes :pid => '0433b37d-ae16-456f-a51d-c7b800334861'
    def test_positive_update_hosts
      new_hosts = 2.times.map { FactoryBot.create(:host, :organization => @organization) }
      @simple_collection.hosts = new_hosts
      assert_valid @simple_collection
      assert_equal 2, @simple_collection.hosts.length
      assert_equal new_hosts.map { |host| host.id }.sort, @simple_collection.hosts.map { |host| host.id }.sort
    end

    test_attributes :pid => '38f67d04-a19d-4eab-a577-21b8d62c7389'
    def test_negative_create_with_invalid_name
      invalid_name_list.each do |name|
        host_collection = HostCollection.new(:name => name, :organization => @organization)
        refute host_collection.valid?, "Validation succeed for create with invalid name: '#{name}' length: #{name.length})"
        assert_includes host_collection.errors.attribute_names, :name
      end
    end

    def test_audit_on_host_collection_creation
      new_host_collection = HostCollection.new(
        :name => "Test Audit Host Collection ",
        :description => 'check audit records',
        :organization_id => Organization.first.id)
      assert_difference 'new_host_collection.audits.count' do
        new_host_collection.save!
      end
    end
  end
end
