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

class NavigationItemsTest < MiniTest::Rails::ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  fixtures :all

  def setup
    Katello.config[:url_prefix] = '/katello'
    @admin = User.find(users(:admin).id)
    User.current = @admin
    @acme_corporation = Organization.find(organizations(:acme_corporation).id)
    Katello.config.stubs(hide_exceptions: true)
  end

  def test_dashboard_item
    item = Navigation::Items::Dashboard.new

    assert_equal  _('Dashboard'), item.display
    assert_equal  dashboard_index_path, item.url
    assert        item.accessible?
  end

  def test_content_seach_item
    item = Navigation::Items::ContentSearch.new(@acme_corporation)

    assert_equal  _('Content Search'), item.display
    assert_equal  content_search_index_path, item.url
    assert        item.accessible?
  end

  def test_content_view_definitions_item
    item = Navigation::Items::ContentViewDefinitions.new(@acme_corporation)

    assert_equal  _('Content View Definitions'), item.display
    assert_equal  content_view_definitions_path, item.url
    assert        item.accessible?
  end

  def test_systems_item
    item = Navigation::Items::Systems.new(@acme_corporation)

    assert_equal  _('All'), item.display
    assert_equal  systems_path, item.url
    assert        item.accessible?
  end

  def test_systems_by_environments_item
    item = Navigation::Items::SystemsByEnvironment.new(@acme_corporation)

    assert_equal  _('By Environment'), item.display
    assert_equal  environments_systems_path, item.url
    assert        item.accessible?
  end

  def test_system_groups_item
    item_item = Navigation::Items::SystemGroups.new(@acme_corporation)

    assert_equal  _('System Groups'), item_item.display
    assert_equal  system_groups_path, item_item.url
    assert        item_item.accessible?
  end

  def test_organizations_item
    item = Navigation::Items::Organizations.new

    assert_equal  _('Organizations'), item.display
    assert_equal  organizations_path, item.url
    assert        item.accessible?
  end

  def test_synchronization_item
    item = Navigation::Items::Synchronization.new

    assert_equal  _('Synchronization'), item.display
    assert_equal  sync_management_manage_path, item.url
    assert        item.accessible?
  end

  def test_users_item
    item = Navigation::Items::Users.new

    assert_equal  _('Users'), item.display
    assert_equal  users_path, item.url
    assert        item.accessible?
  end

  def test_roles_item
    item = Navigation::Items::Roles.new

    assert_equal  _('Roles'), item.display
    assert_equal  roles_path, item.url
    assert        item.accessible?
  end

  def test_item
    item = Navigation::Items::About.new

    assert_equal  _('About'), item.display
    assert_equal  about_path, item.url
    assert        item.accessible?
  end

  def test_changesets_item
    item = Navigation::Items::Changesets.new(@acme_corporation)

    assert_equal  _('Changesets'), item.display
    assert_equal  promotions_path, item.url
    assert        item.accessible?
  end

  def test_changesets_history_item
    item = Navigation::Items::ChangesetHistory.new(@acme_corporation)

    assert_equal  _('Changesets History'), item.display
    assert_equal  changesets_path, item.url
    assert        item.accessible?
  end

  def test_subscriptions_item
    item = Navigation::Items::Subscriptions.new(@acme_corporation)

    assert_equal  _('Red Hat Subscriptions'), item.display
    assert_equal  subscriptions_path, item.url
    assert        item.accessible?
  end

  def test_distributors_item
    item = Navigation::Items::Distributors.new(@acme_corporation)

    assert_equal  _('Subscription Manager Applications'), item.display
    assert_equal  distributors_path, item.url
    assert        item.accessible?
  end

  def test_activation_keys_item
    item = Navigation::Items::ActivationKeys.new(@acme_corporation)

    assert_equal  _('Activation Keys'), item.display
    assert_equal  activation_keys_path, item.url
    assert        item.accessible?
  end

  def test_import_history_item
    item = Navigation::Items::ImportHistory.new(@acme_corporation)

    assert_equal  _('Import History'), item.display
    assert_equal  history_subscriptions_path, item.url
    assert        item.accessible?
  end

  def test_providers_item
    item = Navigation::Items::Providers.new(@acme_corporation)

    assert_equal  _('Custom Content Repositories'), item.display
    assert_equal  providers_path, item.url
    assert        item.accessible?
  end

  def test_redhat_provider_item
    item = Navigation::Items::RedhatProvider.new(@acme_corporation)

    assert_equal  _('Red Hat Repositories'), item.display
    assert_equal  redhat_provider_providers_path, item.url
    assert        item.accessible?
  end

  def test_gpg_keys_item
    item = Navigation::Items::GpgKeys.new(@acme_corporation)

    assert_equal  _('GPG Keys'), item.display
    assert_equal  gpg_keys_path, item.url
    assert        item.accessible?
  end

  def test_sync_status_item
    item = Navigation::Items::SyncStatus.new

    assert_equal  _('Sync Status'), item.display
    assert_equal  sync_management_index_path, item.url
    assert        item.accessible?
  end

  def test_sync_plans_item
    item = Navigation::Items::SyncPlans.new

    assert_equal  _('Sync Plans'), item.display
    assert_equal  sync_plans_path, item.url
    assert        item.accessible?
  end

  def test_sync_schedules_item
    item = Navigation::Items::SyncSchedule.new

    assert_equal  _('Sync Schedule'), item.display
    assert_equal  sync_schedules_index_path, item.url
    assert        item.accessible?
  end

  def test_user_account_item
    item = Navigation::Items::UserAccount.new(@admin)

    assert_equal  _('My Account'), item.display
    assert_equal  "#{users_path(@admin)}#list_search=#{@admin.username}&panel=user_#{@admin.id}&panel_page=edit", item.url
    assert        item.accessible?
  end

  def test_logout_item
    item = Navigation::Items::Logout.new

    assert_equal  _('Sign Out'), item.display
    assert_equal  logout_path, item.url
    assert        item.accessible?
  end

end
