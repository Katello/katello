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

require 'minitest_helper'

class Util::PackageTest < MiniTest::Rails::ActiveSupport::TestCase

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
