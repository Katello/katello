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
    menu = Navigation::Menus::Main.new(@acme_corporation)

    assert_nil    menu.display
    assert_equal  3, menu.items.length
    assert_nil    menu.type
    assert        menu.accessible?
  end

  def test_site_menu
    menu = Navigation::Menus::Site.new

    assert_nil    menu.display
    assert_equal  1, menu.items.length
    assert_nil    menu.type
    assert        menu.accessible?
  end

  def test_content_menu
    menu = Navigation::Menus::Content.new(@acme_corporation)

    assert_equal  _('Content'), menu.display
    assert_equal  6, menu.items.length
    assert_equal  'dropdown', menu.type
    assert        menu.accessible?
  end

  def test_systems_menu
    @systems_menu = Navigation::Menus::Systems.new(@acme_corporation)

    assert_equal  _('Systems'), @systems_menu.display
    assert_equal  3, @systems_menu.items.length
    assert_equal  'dropdown', @systems_menu.type
    assert        @systems_menu.accessible?
  end

  def test_administer_menu
    menu = Navigation::Menus::Administer.new

    assert_equal  _('Administer'), menu.display
    assert_equal  5, menu.items.length
    assert_equal  'dropdown', menu.type
    assert        menu.accessible?
  end

  def test_subscriptions_menu
    menu = Navigation::Menus::Subscriptions.new(@acme_corporation)

    assert_equal  _('Subscriptions'), menu.display
    assert_equal  4, menu.items.length
    assert_equal  'flyout', menu.type
    assert        menu.accessible?
  end

  def test_providers_menu
    menu = Navigation::Menus::Providers.new(@acme_corporation)

    assert_equal  _('Repositories'), menu.display
    assert_equal  3, menu.items.length
    assert_equal  'flyout', menu.type
    assert        menu.accessible?
  end

  def test_sync_management_menu
    menu = Navigation::Menus::SyncManagement.new(@acme_corporation)

    assert_equal  _('Sync Management'), menu.display
    assert_equal  3, menu.items.length
    assert_equal  'flyout', menu.type
    assert        menu.accessible?
  end

  def test_changeset_management_menu
    menu = Navigation::Menus::ChangesetManagement.new(@acme_corporation)

    assert_equal  _('Changeset Management'), menu.display
    assert_equal  2, menu.items.length
    assert_equal  'flyout', menu.type
    assert        menu.accessible?
  end

  def test_user_menu
    menu = Navigation::Menus::User.new(@admin)

    assert_equal  2, menu.items.length
    assert_equal  'dropdown', menu.type
    assert        menu.accessible?
  end

  def test_gravatar
    menu = Navigation::Menus::User.new(@admin)

    Katello.config[:gravatar] ? assert_equal("<img src=\"https:///secure.gravatar.com/avatar/985b643b38ac0b1589b212197e27a143?d=mm&s=25\" class=\"gravatar\"><span class=\"gravatar-span\">admin", menu.display) : assert_equal(@admin.user, menu.display)
    assert        menu.accessible?
  end



end
