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

    class TestMenu < Experimental::Navigation::Menu
      def initialize
        @key           = 'test_menu'
        @display       = 'Test Menu'
        authorization  = true
        @type          = 'dropdown'
        @items         = [
          Experimental::Navigation::Item.new('test_item', 'Test Item', true, 'fake_url'),
          Experimental::Navigation::Item.new('test_item_fails', 'Test Item Fails Authorization', false, 'fake_url')
        ]
        super
      end
    end

  def setup
    @menu = TestMenu.new
  end

  def test_new
    refute_nil @menu
  end

  def test_as_json
    menu_hash = {
      :key    => 'test_menu',
      :display=> 'Test Menu',
      :type   => 'dropdown',
      :items  => [Experimental::Navigation::Item.new('test_item', 'Test Item', true, 'fake_url')]
    }

    assert_equal menu_hash.to_json, @menu.to_json
  end

  def test_prune
    items = @menu.prune
    
    assert_equal 1, items.length
    assert_equal 'test_item', items.first.key
  end

end
