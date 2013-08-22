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


require 'test_helper'

class NavigationItemTest < ActiveSupport::TestCase

  def setup
    @item = Navigation::Item.new('test_item', 'Test Item', true, '/katello/test/item')
  end

  def test_new
    refute_nil @item
  end

  def test_to_json
    item_hash = {
      :key    => 'test_item',
      :display=> 'Test Item',
      :url    => '/katello/test/item'
    }

    assert_equal item_hash.to_json, @item.to_json
  end

end
