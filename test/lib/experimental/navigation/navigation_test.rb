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

class NavigationTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :organizations, :users

  def setup
    @acme_corporation = Organization.find(organizations(:acme_corporation).id)
    @admin            = User.find(users(:admin))
    User.current      = @admin
    Katello.config[:url_prefix] = '/katello'
  end

  def test_new
    navigation = Experimental::Navigation::Menu.new(@acme_corporation)

    refute_nil navigation
  end

  def test_generate_main_menu
    navigation = Experimental::Navigation::Menu.new(@acme_corporation)
    menu = navigation.generate_main_menu

    assert_kind_of Array, menu
  end

end

class NavigationDashboardTest < MiniTest::Rails::ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  fixtures :organizations

  def setup
    @acme_corporation = Organization.find(organizations(:acme_corporation).id)
    @navigation       = Experimental::Navigation::Menu.new(@acme_corporation)
    Katello.config[:url_prefix] = '/katello'
  end

  def test_menu_dashboard
    dashboard = @navigation.menu_dashboard

    assert_equal _('Dashboard'), dashboard[:display]
    assert_equal dashboard_index_path, dashboard[:url]
  end

end

class NavigationContentTest < MiniTest::Rails::ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  fixtures :organizations

  def setup
    @acme_corporation = Organization.find(organizations(:acme_corporation).id)
    @navigation       = Experimental::Navigation::Menu.new(@acme_corporation)
    Katello.config[:url_prefix] = '/katello'
  end

  def test_menu_content
    content = @navigation.menu_content

    assert_equal _('Content'), content[:display]
    assert_nil   content[:url]
    assert_equal 6, content[:items].length
  end

  def test_menu_subscriptions
    content = @navigation.menu_subscriptions

    assert_equal _('Subscriptions'), content[:display]
    assert_equal subscriptions_path, content[:url]
    assert_equal 4, content[:items].length
  end

  def test_menu_repositories
    content = @navigation.menu_repositories

    assert_equal _('Repositories'), content[:display]
    assert_equal providers_path, content[:url]
    assert_equal 3, content[:items].length
  end

  def test_menu_sync_management
    content = @navigation.menu_sync_management

    assert_equal _('Sync Management'), content[:display]
    assert_equal sync_management_index_path, content[:url]
    assert_equal 3, content[:items].length
  end

  def test_menu_content_search
    content = @navigation.menu_content_search

    assert_equal _('Content Search'), content[:display]
    assert_equal content_search_index_path, content[:url]
    assert_nil   content[:items]
  end

  def test_menu_content_view_definitions
    content = @navigation.menu_content_view_definitions

    assert_equal _('Content View Definitions'), content[:display]
    assert_equal content_view_definitions_path, content[:url]
    assert_nil   content[:items]
  end

  def test_menu_changeset_management
    content = @navigation.menu_changeset_management

    assert_equal _('Changeset Management'), content[:display]
    assert_equal promotions_path, content[:url]
    assert_equal 2, content[:items].length
  end

end
