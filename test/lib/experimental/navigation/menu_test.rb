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

class NavigationMenuTest < MiniTest::Rails::ActiveSupport::TestCase

  def setup
    @menu = Experimental::Navigation::Menu.new('test_item', 'Test Item', true, 'dropdown', [{}])
  end

  def test_new
    refute_nil @menu
  end

  def test_to_json
    menu_hash = {
      :key    => 'test_item',
      :display=> 'Test Item',
      :type   => 'dropdown',
      :items  => [{}]
    }

    assert_equal menu_hash.to_json, @menu.to_json
  end

end
