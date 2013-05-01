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

class ContentTypeTest < MiniTest::Rails::ActiveSupport::TestCase
   def assert_package_type
     assert_equal(Package::CONTENT_TYPE, Runcible::Extensions::Rpm.content_type())
   end

   def assert_package_group_type
     assert_equal(PackageGroup::CONTENT_TYPE, Runcible::Extensions::PackageGroup.content_type())
   end

   def assert_erratum_type
     assert_equal(Errata::CONTENT_TYPE, Runcible::Extensions::Errata.content_type())
   end
end