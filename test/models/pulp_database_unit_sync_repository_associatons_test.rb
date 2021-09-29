# encoding: utf-8

require 'katello_test_helper'

module Katello
  class PulpDatabaseUnitSyncRepositoryAssociationsTest < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def test_non_generic_content_type_associates_new_ids_and_removes_missing_ids_in_map
      @repo = FactoryBot.create(:katello_repository, :with_product)

      @rpm = katello_rpms(:one)
      @rpm2 = katello_rpms(:two)
      @rpm3 = katello_rpms(:three)
      @rpm4 = Katello::Rpm.new
      @rpm4.update(:name => "four", :filename => "four-1.1.rpm", :arch => "i386", :pulp_id => "four-uuid")
      @rpm5 = Katello::Rpm.new
      @rpm5.update(:name => "five", :filename => "five-1.1.rpm", :version => 2.0, :epoch => 0, :pulp_id => "five-uuid")

      @repo.rpms = [@rpm, @rpm2, @rpm3, @rpm4, @rpm5]

      pulp_id_ref_map = {
        @rpm.pulp_id => nil,
        @rpm2.pulp_id => nil
      }

      Katello::Rpm.sync_repository_associations(@repo, pulp_id_href_map: pulp_id_ref_map)

      rpm_ids = Katello::Rpm.repository_association_class.where(repository_id: @repo).pluck(:rpm_id)
      assert_includes rpm_ids, @rpm.id
      assert_includes rpm_ids, @rpm2.id

      refute_includes rpm_ids, @rpm3.id
      refute_includes rpm_ids, @rpm4.id
      refute_includes rpm_ids, @rpm5.id
    end

    def test_generic_different_content_types_associates_new_ids_and_removes_missing_ids_in_map
      @repo = katello_repositories(:pulp3_python_1)

      @gcu = Katello::GenericContentUnit.create(name: "one", pulp_id: "one-uuid", content_type: "first")
      @gcu2 = Katello::GenericContentUnit.create(name: "two", pulp_id: "two-uuid", content_type: "second")
      @gcu3 = Katello::GenericContentUnit.create(name: "three", pulp_id: "three-uuid", content_type: "third")

      @repo.generic_content_units = [@gcu, @gcu2]

      pulp_id_ref_map = {
        @gcu2.pulp_id => nil
      }

      Katello::GenericContentUnit.sync_repository_associations(
        @repo, pulp_id_href_map: pulp_id_ref_map, generic_content_type: @gcu2.content_type)

      gcu_ids = Katello::GenericContentUnit.repository_association_class.where(repository_id: @repo).pluck(:generic_content_unit_id)
      assert_includes gcu_ids, @gcu.id
      assert_includes gcu_ids, @gcu2.id

      pulp_id_ref_map = {}

      Katello::GenericContentUnit.sync_repository_associations(
        @repo, pulp_id_href_map: pulp_id_ref_map, generic_content_type: @gcu.content_type)

      gcu_ids = Katello::GenericContentUnit.repository_association_class.where(repository_id: @repo).pluck(:generic_content_unit_id)
      refute_includes gcu_ids, @gcu.id
      assert_includes gcu_ids, @gcu2.id
    end
  end
end
