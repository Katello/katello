# encoding: utf-8
#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
