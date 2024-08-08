require 'katello_test_helper'
require 'rake'

module Katello
  class UpdateContentImportExportPermsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/4.1/reupdate_content_import_export_perms'
      Rake::Task['katello:upgrades:4.1:reupdate_content_import_export_perms'].reenable
      Rake::Task.define_task(:environment)
    end

    def test_reupdate_content_import_export_perms
      old_perm_names = %w[export_content_views export_library_content import_library_content].freeze

      old_perms = old_perm_names.collect do |perm_name|
        FactoryBot.create(:permission, name: perm_name, resource_type: 'Organization')
      end

      FactoryBot.create(:role, name: 'old content tester', permissions: old_perms)

      assert_equal Permission.where(name: old_perm_names).size, 3
      assert_equal Filtering.where(permission_id: old_perms.collect(&:id)).size, 3

      Rake.application.invoke_task('katello:upgrades:4.1:reupdate_content_import_export_perms')

      assert_equal Permission.where(name: old_perm_names).size, 0
      assert_equal Filtering.where(permission_id: old_perms.collect(&:id)).size, 0
    end

    def test_reupdate_content_import_export_perms_both_library_and_regular
      # This tests the case were the user has a role with perms
      # export_library_content, export_content, import_library_content, import_content
      # The execution of upgrade task must eliminate  import_library_content and
      # export_library_content (instead of moving it)
      # So post upgrade  you should expect to see -> [import_content, export_content]
      #
      old_perm_names = %w[export_library_content import_library_content].freeze
      new_perm_names = %w[export_content import_content].freeze

      old_perms = old_perm_names.collect do |perm_name|
        FactoryBot.create(:permission, name: perm_name, resource_type: 'Organization')
      end
      new_perms = new_perm_names.map do |perm_name|
        Permission.find_by(name: perm_name)
      end

      role = FactoryBot.create(:role, name: 'old content tester', permissions: old_perms + new_perms)
      assert_equal 2, Permission.where(name: new_perm_names).count
      assert_equal 2, Filtering.where(filter_id: role.filters.select(:id), permission_id: new_perms.map(&:id)).count

      assert_equal Permission.where(name: old_perm_names).count, 2
      assert_equal Filtering.where(permission_id: old_perms.map(&:id)).count, 2

      Rake.application.invoke_task('katello:upgrades:4.1:reupdate_content_import_export_perms')

      assert_equal Permission.where(name: old_perm_names).count, 0
      assert_equal Filtering.where(permission_id: old_perms.map(&:id)).count, 0

      assert_equal 2, Permission.where(name: new_perm_names).count
      assert_equal 2, Filtering.where(filter_id: role.filters.select(:id), permission_id: new_perms.map(&:id)).count
    end

    def test_reupdate_content_import_export_perms_duplicated
      # This tests the case were the user has a role with duplicate perms
      # export_content, export_content, import_content, import_content
      # The execution of upgrade task must eliminate  one import_content and
      # and one export_content
      # So post upgrade  you should expect to see -> [import_content, export_content]
      #
      old_perm_names = %w[export_library_content import_library_content].freeze
      old_perms = old_perm_names.map do |perm_name|
        FactoryBot.create(:permission, name: perm_name, resource_type: 'Organization')
      end

      new_perm_names = %w[export_content import_content].freeze
      new_perms = new_perm_names.map do |perm_name|
        Permission.find_by(name: perm_name)
      end

      role = FactoryBot.create(:role, name: 'old content tester', permissions: old_perms + new_perms)

      assert_equal 4, Permission.where(name: old_perm_names + new_perm_names).count

      # Now just rename import_libray_content to import_content
      permission_map = {
        Permission.find_by(name: :export_library_content) => Permission.find_by(name: :export_content),
        Permission.find_by(name: :import_library_content) => Permission.find_by(name: :import_content),
      }
      permission_map.each do |old_perm, new_perm|
        Filtering.where(permission_id: old_perm.id).update_all(:permission_id => new_perm.id)
      end
      Permission.where(:name => old_perm_names).destroy_all
      assert_equal 4, Filtering.where(filter_id: role.filters.select(:id), permission_id: new_perms.map(&:id)).count

      Rake.application.invoke_task('katello:upgrades:4.1:reupdate_content_import_export_perms')

      assert_equal 2, Filtering.where(filter_id: role.filters.select(:id), permission_id: new_perms.map(&:id)).count
    end

    def test_update_export_content_views
      old_perm_names = %w[export_content_views view_content_views].freeze

      old_perms = old_perm_names.collect do |perm_name|
        Permission.find_by_name(perm_name) || FactoryBot.create(:permission, name: perm_name, resource_type: "Katello::ContentView")
      end

      role = FactoryBot.create(:role, name: 'old content tester', permissions: old_perms)

      old_filtering_count = Filtering.where(permission_id: old_perms.collect(&:id)).size
      assert_equal Permission.where(name: old_perm_names).size, 2
      assert_equal role.filters.size, 1

      Rake.application.invoke_task('katello:upgrades:4.1:reupdate_content_import_export_perms')

      assert_equal Permission.where(name: old_perm_names).size, 1
      assert_equal Filtering.where(permission_id: old_perms.collect(&:id)).size, old_filtering_count - 1
      assert_equal role.filters.size, 2
    end
  end
end
