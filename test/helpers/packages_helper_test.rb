# encoding: utf-8

require "katello_test_helper"

module Katello
  class PackagesHelperTest < ActionView::TestCase
    def test_format_package_details
      package = { :name => 'package-a' }
      assert_equal "package-a", format_package_details(package)

      package[:flags] = 'EQ'
      package[:version] = '1.2.0'
      assert_equal "package-a = 1.2.0", format_package_details(package)

      package[:epoch] = '9'
      assert_equal "package-a = 9:1.2.0", format_package_details(package)

      package[:release] = '3'
      assert_equal "package-a = 9:1.2.0-3", format_package_details(package)
    end
  end
end
