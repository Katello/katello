require 'katello_test_helper'
require 'rake'

module Katello
  class CleanInstalledPackagesTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/clean_installed_packages'
      Rake::Task['katello:clean_installed_packages'].reenable
      Rake::Task.define_task(:environment)
      @host = hosts(:one)
    end

    def test_missing_nil_uuid
      nvra = 'foo-1.2.3'
      pkgs = []
      5.times do
        pkgs << Katello::InstalledPackage.create!(:nvra => nvra, :name => 'foo')
      end

      hosts(:one).installed_packages << pkgs[0]
      hosts(:two).installed_packages << pkgs[1]

      Rake.application.invoke_task('katello:clean_installed_packages')

      assert_equal 1, Katello::InstalledPackage.where(:nvra => nvra).count
      assert hosts(:one).installed_packages.where(:nvra => nvra).count == 1
      assert hosts(:two).installed_packages.where(:nvra => nvra).count == 1
    end
  end
end
