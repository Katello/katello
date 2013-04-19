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
    skip
    @main_menu = Experimental::Navigation::Menus::Main.new(@acme_corporation)

    assert_nil    @main_menu.display
    assert_equal  3, @main_menu.items.length
    assert_equal  'dropdown', @main_menu.type
    assert        @main_menu.accessible?
  end

  def test_content_menu
    @content_menu = Experimental::Navigation::Menus::Content.new(@acme_corporation)

    assert_equal  _('Content'), @content_menu.display
    assert_equal  6, @content_menu.items.length
    assert_equal  'dropdown', @content_menu.type
    assert        @content_menu.accessible?
  end

  def test_systems_menu
    @systems_menu = Experimental::Navigation::Menus::Systems.new(@acme_corporation)

    assert_equal  _('Systems'), @systems_menu.display
    assert_equal  3, @systems_menu.items.length
    assert_equal  'dropdown', @systems_menu.type
    assert        @systems_menu.accessible?
  end

  def test_administer_menu
    administer_menu = Experimental::Navigation::Menus::Administer.new

    assert_equal  _('Administer'), administer_menu.display
    assert_equal  5, administer_menu.items.length
    assert_equal  'dropdown', administer_menu.type
    assert        administer_menu.accessible?
  end

  def test_subscriptions_menu
    @subscriptions_menu = Experimental::Navigation::Menus::Subscriptions.new(@acme_corporation)

    assert_equal  _('Subscriptions'), @subscriptions_menu.display
    assert_equal  4, @subscriptions_menu.items.length
    assert_equal  'flyout', @subscriptions_menu.type
    assert        @subscriptions_menu.accessible?
  end

  def test_providers_menu
    @providers_menu = Experimental::Navigation::Menus::Providers.new(@acme_corporation)

    assert_equal  _('Repositories'), @providers_menu.display
    assert_equal  3, @providers_menu.items.length
    assert_equal  'flyout', @providers_menu.type
    assert        @providers_menu.accessible?
  end

  def test_sync_management_menu
    @sync_management_menu = Experimental::Navigation::Menus::SyncManagement.new(@acme_corporation)

    assert_equal  _('Sync Management'), @sync_management_menu.display
    assert_equal  3, @sync_management_menu.items.length
    assert_equal  'flyout', @sync_management_menu.type
    assert        @sync_management_menu.accessible?
  end

  def test_changeset_management_menu
    @changeset_management_menu = Experimental::Navigation::Menus::ChangesetManagement.new(@acme_corporation)

    assert_equal  _('Changeset Management'), @changeset_management_menu.display
    assert_equal  2, @changeset_management_menu.items.length
    assert_equal  'flyout', @changeset_management_menu.type
    assert        @changeset_management_menu.accessible?
  end

  def test_user_menu
    menu = Experimental::Navigation::Menus::User.new(@admin)

    assert_equal  @admin.username, menu.display
    assert_equal  2, menu.items.length
    assert_equal  'dropdown', menu.type
    assert        menu.accessible?
  end

end
