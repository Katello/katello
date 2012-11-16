#
# Copyright 2012 Red Hat, Inc.
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

=begin
class RepositoryElasticSearchTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

  def test_extended_index_attrs
    assert @fedora_17.extended_index_attrs.is_a? Hash
  end

  def test_update_related_index
    assert @fedora_17.update_related_index
  end

  def test_index_packages
    assert @fedora_17.index_packages
  end

  def test_errata_count
    assert @fedora_17.errata_count
  end

  def test_package_count
    assert @fedora_17.package_count
  end

end
=end
