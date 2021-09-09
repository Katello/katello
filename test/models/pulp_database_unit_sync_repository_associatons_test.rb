# encoding: utf-8

require 'katello_test_helper'

module Katello
  class PulpDatabaseUnitSyncRepositoryAssociationsTest < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def setup
    end

    def test_non_generic_content_type_associates_new_ids_and_removes_missing_ids_in_map
      @repo = FactoryBot.create(:katello_repository, :with_product)
      @content_type = Katello::RepositoryTypeManager.find_content_type('rpm')
      @service_class = @content_type.pulp3_service_class
      @rpm = katello_rpms(:one)
      @rpm2 = katello_rpms(:two)
      @rpm3 = katello_rpms(:three)
      @rpm4 = Katello::Rpm.new
      @rpm4.update(:name => "four", :filename => "four-1.1.rpm", :arch => "i386", :pulp_id => "four-uuid")
      @rpm5 = Katello::Rpm.new
      @rpm5.update(:name => "five", :filename => "five-1.1.rpm", :version => 2.0, :epoch => 0, :pulp_id => "five-uuid")

      @repo.rpms = [@rpm, @rpm2, @rpm3, @rpm4, @rpm5]

      indexer = Katello::ContentUnitIndexer.new(content_type: @content_type, repository: @repo)
      tracker = Katello::ContentUnitIndexer::RepoAssociationTracker.new(@content_type, @service_class, @repo)

      [@rpm, @rpm2].each { |rpm| tracker.push({pulp_href: rpm.pulp_id}.with_indifferent_access) }
      indexer.sync_repository_associations(tracker)

      rpm_ids = Katello::Rpm.repository_association_class.where(repository_id: @repo).pluck(:rpm_id)
      assert_includes rpm_ids, @rpm.id
      assert_includes rpm_ids, @rpm2.id

      refute_includes rpm_ids, @rpm3.id
      refute_includes rpm_ids, @rpm4.id
      refute_includes rpm_ids, @rpm5.id
    end

    def test_generic_different_content_types_associates_new_ids_and_removes_missing_ids_in_map
      @content_type = Katello::RepositoryTypeManager.find_content_type('python_package')
      @service_class = @content_type.pulp3_service_class
      @repo = katello_repositories(:pulp3_python_1)

      @gcu = Katello::GenericContentUnit.create(name: "one", pulp_id: "one-uuid", content_type: "first")
      @gcu2 = Katello::GenericContentUnit.create(name: "two", pulp_id: "two-uuid", content_type: "second")
      @gcu3 = Katello::GenericContentUnit.create(name: "three", pulp_id: "three-uuid", content_type: "third")

      @repo.generic_content_units = [@gcu, @gcu2]

      indexer = Katello::ContentUnitIndexer.new(content_type: @content_type, repository: @repo)
      tracker = Katello::ContentUnitIndexer::RepoAssociationTracker.new(@content_type, @service_class, @repo)
      tracker.push({pulp_href: @gcu.pulp_id}.with_indifferent_access)
      tracker.push({pulp_href: @gcu2.pulp_id}.with_indifferent_access)

      indexer.sync_repository_associations(tracker)

      gcu_ids = Katello::GenericContentUnit.repository_association_class.where(repository_id: @repo).pluck(:generic_content_unit_id)
      assert_includes gcu_ids, @gcu.id
      assert_includes gcu_ids, @gcu2.id

      tracker = Katello::ContentUnitIndexer::RepoAssociationTracker.new(@content_type, @service_class, @repo)
      tracker.push({pulp_href: @gcu2.pulp_id}.with_indifferent_access)

      indexer.sync_repository_associations(tracker)

      gcu_ids = Katello::GenericContentUnit.repository_association_class.where(repository_id: @repo).pluck(:generic_content_unit_id)
      refute_includes gcu_ids, @gcu.id
      assert_includes gcu_ids, @gcu2.id
    end
  end
end
