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

  class TestMenu < Navigation::Menu
    def initialize
      @key           = 'test_menu'
      @display       = 'Test Menu'
      @authorization  = true
      @type          = 'dropdown'
      @items         = [
        Navigation::Item.new('test_item', 'Test Item', true, 'fake_url'),
        Navigation::Item.new('test_item_fails', 'Test Item Fails Authorization', false, 'fake_url')
      ]
      super
    end
  end


  def setup
    @menu = TestMenu.new
  end

  def teardown
    Navigation::Additions.clear
  end

  def test_new
    refute_nil @menu
  end

  def test_as_json
    menu_hash = {
      :key    => 'test_menu',
      :display=> 'Test Menu',
      :type   => 'dropdown',
      :items  => [Navigation::Item.new('test_item', 'Test Item', true, 'fake_url')]
    }

    assert_equal menu_hash.to_json, @menu.to_json
  end

  def test_prune
    items = @menu.prune

    assert_equal 1, items.length
    assert_equal 'test_item', items.first.key
  end

end


class NavigationAdditionsMenuTest < MiniTest::Rails::ActiveSupport::TestCase


  class TestMenu < Navigation::Menu
    def initialize
      @key           = 'test_menu'
      @display       = 'Test Menu'
      @authorization  = true
      @type          = 'dropdown'
      @items         = [
        Navigation::Item.new('test_item', 'Test Item', true, 'fake_url'),
        Navigation::Item.new('test_item_fails', 'Test Item Fails Authorization', false, 'fake_url')
      ]
      super
    end
  end

  class TestItem < Navigation::Item

    def initialize
      @key           = 'test_item_foo'
      @display       = _("Some test item")
      @authorization = true
      @url           = 'fake url'
    end

  end

  class TestMenuChild < Navigation::Menu
    def initialize
      @key           = 'test_menu_child'
      @display       = 'Test Child Menu'
      @authorization  = true
      @type          = 'dropdown'
      @items         = [
        Navigation::Item.new('test_item_child', 'Child item', true, 'fake_url')
      ]
      super
    end
  end

  class TestMenuParent < Navigation::Menu
    def initialize
      @key           = 'test_menu_parent'
      @display       = 'Test Parent Menu'
      authorization  = true
      @items         = [
        TestMenuChild.new
      ]
      super
    end
  end


  def teardown
    Navigation::Additions.clear
  end

  def test_add_additions_delete
    Navigation::Additions.delete(:test_item)
    menu = TestMenu.new

    assert_empty menu.items.select{|i| i.key == :test_item }
  end

  def test_add_additions_insert_before
    Navigation::Additions.insert_before(:test_item, TestItem)
    menu = TestMenu.new

    assert_equal TestItem.new.key, menu.items[0].key
  end

  def test_add_additions_insert_after

    Navigation::Additions.insert_after(:test_item, TestItem)
    menu = TestMenu.new

    assert_equal TestItem.new.key, menu.items[1].key
  end

  def test_add_additions_insert_to_child
    Navigation::Additions.insert_after(:test_item_child, TestItem)
    menu = TestMenuParent.new

    child =  menu.items.first
    assert_equal 'test_menu_child', child.key
    assert_equal 'test_item_foo', child.items[1].key
  end
end
