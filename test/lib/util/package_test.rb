require 'katello_test_helper'

module Katello
  class Util::PackageTest < ActiveSupport::TestCase
    def test_sortable_version
      # Examples pulled from Pulp documentation
      # http://pulp-rpm-dev-guide.readthedocs.org/en/latest/sort-index.html
      assert_equal "01-3.01-9", Util::Package.sortable_version("3.9")
      assert_equal "01-3.02-10", Util::Package.sortable_version("3.10")
      assert_equal "01-5.03-256", Util::Package.sortable_version("5.256")
      assert_equal "01-1.01-1.$a", Util::Package.sortable_version("1.1a")
      assert_equal "01-1.$a", Util::Package.sortable_version("1.a+")
      assert_equal "02-12.$a.01-3.$bc", Util::Package.sortable_version("12a3bc")
      assert_equal "01-2.$xFg.02-33.$f.01-5", Util::Package.sortable_version("2xFg33.+f.5")
    end

    def test_latest_packages
      packages = [
        # This should be the latest
        {:epoch => '10', :version => '3.10', :release => '3.10'},
        # Make sure epoch has priority over version and release
        # and 2-digit epoch is handled properly
        {:epoch => '9', :version => '4', :release => '4'},
        # Make sure version has priority over release
        {:epoch => '10', :version => '2', :release => '4'},
        # Make sure sortable version is used
        {:epoch => '10', :version => '3.2', :release => '4'},
        # Make sure sortable release is used
        {:epoch => '10', :version => '3.10', :release => '3.2'},
        # Make sure multiple packages with the same version and different names
        # are handled properly
        {:epoch => '9', :version => '4', :release => '4'},
        {:epoch => '10', :version => '2', :release => '4'},
        {:epoch => '10', :version => '3.2', :release => '4'},
        {:epoch => '10', :version => '3.10', :release => '3.2'},
        {:epoch => '10', :version => '3.10', :release => '3.10'}
      ]
      packages.each do |package|
        package[:version_sortable] = Util::Package.sortable_version(package[:version])
        package[:release_sortable] = Util::Package.sortable_version(package[:release])
      end
      expected_packages = [
        packages[0].with_indifferent_access,
        packages[-1].with_indifferent_access
      ]
      assert_equal expected_packages, Util::Package.find_latest_packages(packages)
    end
  end
end
