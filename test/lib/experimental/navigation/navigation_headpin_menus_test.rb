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

class NavigationMenusTest < MiniTest::Rails::ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  fixtures :all

  def setup
    Katello.config[:url_prefix] = '/katello'
    @admin = User.find(users(:admin).id)
    User.current = @admin
    @acme_corporation = Organization.find(organizations(:acme_corporation).id)
  end

  def test_main_menu
    menu = Experimental::Navigation::Menus::Main.new(@acme_corporation)

    assert_nil    menu.display
    assert_equal  3, menu.items.length
    assert_nil    menu.type
    assert        menu.accessible?
  end

  def test_site_menu
    menu = Experimental::Navigation::Menus::Site.new

    assert_nil    menu.display
    assert_equal  1, menu.items.length
    assert_nil    menu.type
    assert        menu.accessible?
  end

  def test_content_menu
    menu = Experimental::Navigation::Menus::Content.new(@acme_corporation)

    assert_equal  _('Content'), menu.display
    assert_equal  2, menu.items.length
    assert_equal  'dropdown', menu.type
    assert        menu.accessible?
  end

  def test_systems_menu
    @systems_menu = Experimental::Navigation::Menus::Systems.new(@acme_corporation)

    assert_equal  _('Systems'), @systems_menu.display
    assert_equal  2, @systems_menu.items.length
    assert_equal  'dropdown', @systems_menu.type
    assert        @systems_menu.accessible?
  end

  def test_administer_menu
    menu = Experimental::Navigation::Menus::Administer.new

    assert_equal  _('Administer'), menu.display
    assert_equal  4, menu.items.length
    assert_equal  'dropdown', menu.type
    assert        menu.accessible?
  end

  def test_subscriptions_menu
    menu = Experimental::Navigation::Menus::Subscriptions.new(@acme_corporation)

    assert_equal  _('Subscriptions'), menu.display
    assert_equal  4, menu.items.length
    assert_equal  'flyout', menu.type
    assert        menu.accessible?
  end

  def test_providers_menu
    menu = Experimental::Navigation::Menus::Providers.new(@acme_corporation)

    assert_equal  _('Repositories'), menu.display
    assert_equal  1, menu.items.length
    assert_equal  'flyout', menu.type
    assert        menu.accessible?
  end

  def test_user_menu
    menu = Experimental::Navigation::Menus::User.new(@admin)

    assert_equal  @admin.username, menu.display
    assert_equal  2, menu.items.length
    assert_equal  'dropdown', menu.type
    assert        menu.accessible?
  end

end
