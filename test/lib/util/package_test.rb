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
  end
end
