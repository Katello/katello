require 'katello_test_helper'
require 'rake'

module Katello
  class UpdateContentImportExportPermsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/4.1/update_content_import_export_perms'
      Rake::Task['katello:upgrades:4.1:update_content_import_export_perms'].reenable
      Rake::Task.define_task(:environment)
    end

    def test_update_content_import_export_perms
      old_perm_names = %w[export_content_views export_library_content import_library_content].freeze

      old_perms = old_perm_names.collect do |perm_name|
        FactoryBot.create(:permission, name: perm_name)
      end

      FactoryBot.create(:role, name: 'old content tester', permissions: old_perms)

      assert_equal Permission.where(name: old_perm_names).size, 3
      assert_equal Filtering.where(permission_id: old_perms.collect(&:id)).size, 3

      Rake.application.invoke_task('katello:upgrades:4.1:update_content_import_export_perms')

      assert_equal Permission.where(name: old_perm_names).size, 0
      assert_equal Filtering.where(permission_id: old_perms.collect(&:id)).size, 0
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

      Rake.application.invoke_task('katello:upgrades:4.1:update_content_import_export_perms')

      assert_equal Permission.where(name: old_perm_names).size, 1
      assert_equal Filtering.where(permission_id: old_perms.collect(&:id)).size, old_filtering_count - 1
      assert_equal role.filters.size, 2
    end
  end
end
