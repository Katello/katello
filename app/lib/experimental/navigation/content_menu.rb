#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Experimental
  module Navigation
    module ContentMenu

      def menu_content
        {
          :key     => :content,
          :display => _("Content"),
          :if      => lambda{@current_organization},
          :type    => 'dropdown',
          :items   => [
            menu_subscriptions,
            menu_repositories,
            menu_sync_management,
            menu_content_search,
            menu_content_view_definitions,
            menu_changeset_management
          ]
        }
      end

      def menu_subscriptions
        {
          :key    => :subscriptions,
          :display=> _("Subscriptions"),
          :url    => subscriptions_path,
          :if     => lambda{ @current_organization },
          :type   => 'flyout',
          :items  => [
            {
              :key    => :red_hat_subscriptions,
              :display=> _("Red Hat Subscriptions"),
              :url    => subscriptions_path,
              :if     => lambda{ @current_organization.redhat_provider.readable? },
            },{
              :key    => :distributors_list,
              :display=> _("Subscription Manager Applications"),
              :url    => distributors_path,
              :if     => lambda{ @current_organization && @current_organization.readable? }
            },{
              :key    => :activation_keys,
              :display=> _("Activation Keys"),
              :url    => activation_keys_path,
              :if     => lambda{ @current_organization && ActivationKey.readable?(@current_organization) }
            },{
              :key    => :import_history,
              :display=> _("Import History"),
              :url    => history_subscriptions_path,
              :if     => lambda{ @current_organization && @current_organization.readable? }
            }
          ]
        }
      end

      def menu_repositories
        {
          :key    => :providers,
          :display=> _("Repositories"),
          :url    => providers_path,
          :type   => 'flyout',
          :items  => [
            {
              :key    => :redhat_providers,
              :display=> _("Red Hat Repositories"),
              :url    => redhat_provider_providers_path,
              :if     => lambda{ @current_organization && @current_organization.readable? },
            },{
              :key    => :custom_providers,
              :display=> _("Custom Content Repositories"),
              :url    => providers_path,
              :if     => lambda{ Katello.config.katello? && @current_organization && Provider.any_readable?(@current_organization) },
            },{
              :key    => :gpg,
              :display=> _("GPG Keys"),
              :url    => gpg_keys_path,
              :if     => lambda{ GpgKey.any_readable?(@current_organization) },
           }
          ]
        }
      end

      def menu_sync_management
        {
          :key    => :sync_mgmt,
          :display=> _("Sync Management"),
          :url    => sync_management_index_path,
          :type   => 'flyout',
          :if     => lambda{ Katello.config.katello? && (@current_organization.syncable? || Provider.any_readable?(@current_organization)) },
          :items  => [
            {
              :key    => :sync_status,
              :display=> _("Sync Status"),
              :url    => sync_management_index_path
            },{
              :key    => :sync_plans,
              :display=> _("Sync Plans"),
              :url    => sync_plans_path
            },{
              :key    => :sync_schedule,
              :display=> _("Sync Schedule"),
              :url    => sync_schedules_index_path
            }
          ]
        }
      end

      def menu_content_search
        {
          :key    => :content_search,
          :display=> _("Content Search"),
          :if     => lambda{ Katello.config.katello? && !KTEnvironment.content_readable(@current_organization).empty? },
          :url    => content_search_index_path
        }
      end

      def menu_content_view_definitions
        {
          :key    => :content_view_definitions,
          :display=> _("Content View Definitions"),
          :if     => lambda{Katello.config.katello? && ContentViewDefinition.any_readable?(@current_organization) },
          :url    => content_view_definitions_path
        }
      end

      def menu_changeset_management
        {
          :key    => :changeset_management,
          :display=> _("Changeset Management"),
          :url    => promotions_path,
          :type   => 'flyout',
          :if     => lambda{ Katello.config.katello? && KTEnvironment.any_viewable_for_promotions?(@current_organization) },
          :items  => [
            {
              :key    => :changesets,
              :display=> _("Changesets"),
              :url    => promotions_path,
              :if     => lambda{ Katello.config.katello? && KTEnvironment.any_viewable_for_promotions?(@current_organization) }
            },{
              :key    => :changeset,
              :display=> _("Changesets History"),
              :url    => changesets_path,
              :if     => lambda{ Katello.config.katello? && KTEnvironment.any_viewable_for_promotions?(@current_organization) }
           }
          ]
        }
      end

    end
  end
end
